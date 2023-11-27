# frozen_string_literal: true

require "digest"

module Inoculate
	# Registers and builds dependency injection modules.
	#
	# @since 0.1.0
	class Manufacturer
		# The set of registered blueprints for dependency injection modules.
		# @return [Hash<Symbol, Hash>]
		#
		# @since 0.1.0
		attr_reader :registered_blueprints

		def initialize
			@registered_blueprints = {}
		end

		# Register a transient dependency.
		#
		# A transient dependency gets created anew every time it is retrieved through the accessor.
		#
		# @example With a block
		#   manufacturer.transient(:sha1_hasher) { Digest::SHA1.new }
		#
		# @example With a Proc
		#   manufacturer.transient(:sha1_hasher, &-> { Digest::SHA1.new })
		#
		# @param name [Symbol, #to_sym] the dependency name which will be used to access it
		# @param block [Block, Proc] a factory method to build the dependency
		#
		# @raise [Errors::RequiresCallable] if no block is provided
		# @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
		#                              or is not a valid attribute name
		# @raise [Errors::AlreadyRegistered] if the name has been registered previously
		#
		# @since 0.1.0
		def transient(name, &block)
			register_blueprint(name, :transient, &block)
		end

		# Register an instance dependency.
		#
		# An instance dependency gets created once for each instance of a dependent class.
		#
		# @example With a block
		#   manufacturer.instance(:sha1_hasher) { Digest::SHA1.new }
		#
		# @example With a Proc
		#   manufacturer.instance(:sha1_hasher, &-> { Digest::SHA1.new })
		#
		# @param name [Symbol, #to_sym] the dependency name which will be used to access it
		# @param block [Block, Proc] a factory method to build the dependency
		#
		# @raise [Errors::RequiresCallable] if no block is provided
		# @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
		#                              or is not a valid attribute name
		# @raise [Errors::AlreadyRegistered] if the name has been registered previously
		#
		# @since 0.3.0
		def instance(name, &block)
			register_blueprint(name, :instance, &block)
		end

		# Register a singleton dependency.
		#
		# A singleton dependency gets created once.
		#
		# @example With a block
		#   manufacturer.singleton(:sha1_hasher) { Digest::SHA1.new }
		#
		# @example With a Proc
		#   manufacturer.singleton(:sha1_hasher, &-> { Digest::SHA1.new })
		#
		# @param name [Symbol, #to_sym] the dependency name which will be used to access it
		# @param block [Block, Proc] a factory method to build the dependency
		#
		# @raise [Errors::RequiresCallable] if no block is provided
		# @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
		#                              or is not a valid attribute name
		# @raise [Errors::AlreadyRegistered] if the name has been registered previously
		#
		# @since 0.4.0
		def singleton(name, &block)
			register_blueprint(name, :singleton, &block)
		end

		# Register a thread singleton dependency.
		#
		# A thread singleton dependency gets created once per thread or fiber.
		#
		# @example With a block
		#   manufacturer.thread_singleton(:sha1_hasher) { Digest::SHA1.new }
		#
		# @example With a Proc
		#   manufacturer.thread_singleton(:sha1_hasher, &-> { Digest::SHA1.new })
		#
		# @param name [Symbol, #to_sym] the dependency name which will be used to access it
		# @param block [Block, Proc] a factory method to build the dependency
		#
		# @raise [Errors::RequiresCallable] if no block is provided
		# @raise [Errors::InvalidName] if the name is not a symbol, cannot be converted to a symbol,
		#                              or is not a valid attribute name
		# @raise [Errors::AlreadyRegistered] if the name has been registered previously
		#
		# @since 0.5.0
		def thread_singleton(name, &block)
			register_blueprint(name, :thread_singleton, &block)
		end

		private

			def register_blueprint(name, lifecycle, &block)
				validate_dependency_name name
				raise Errors::AlreadyRegistered if @registered_blueprints.key? name
				raise Errors::RequiresCallable if block.nil?

				blueprint_name = name.to_sym
				@registered_blueprints[blueprint_name] = {
					lifecycle: lifecycle,
					factory: block,
					accessor_module: build_module(blueprint_name, lifecycle, block)
				}
			end

			def build_module(name, lifecycle, factory)
				module_name = "I#{hash_name(name)}"
				module_body =
					case lifecycle
					when :transient then build_transient(name, factory)
					when :instance then build_instance(name, factory)
					when :singleton then build_singleton(name, factory)
					when :thread_singleton then build_thread_singleton(name, factory)
					else raise ArgumentError, "Life cycle #{lifecycle} is not valid. Something has gone very wrong."
					end

				Providers.module_eval { const_set(module_name, module_body) }
			end

			def build_transient(name, factory)
				t = Lifecycle::Transient.new(&factory)
				Module.new do
					private define_method(name) { t.obtain }
				end
			end

			def build_instance(name, factory)
				cache_variable_name = "@icache_#{hash_name(name)}"
				Module.new do
					private

						define_method(name) do
							instance_variable_set(cache_variable_name, factory.call) \
								unless instance_variable_defined?(cache_variable_name)
							instance_variable_get(cache_variable_name)
						end
				end
			end

			def build_singleton(name, factory)
				cache_variable_name = "@_inoculate_cache_#{hash_name(name)}"
				Module.new do |mod|
					private

						define_method(name) do
							mod.instance_variable_set(cache_variable_name, factory.call) \
								unless mod.instance_variable_defined?(cache_variable_name)
							mod.instance_variable_get(cache_variable_name)
						end
				end
			end

			def build_thread_singleton(name, factory)
				thread_variable_name = "icache_#{hash_name(name)}"
				Module.new do
					private define_method(name) { Thread.current[thread_variable_name] ||= factory.call }
				end
			end

			def validate_dependency_name(name)
				raise Errors::InvalidName, "name must be a symbol or convert to one" unless name.respond_to? :to_sym

				begin
					Module.new { attr_reader name }
				rescue NameError
					raise Errors::InvalidName, "name must be a valid attr_reader"
				end
			end

			def hash_name(name)
				Digest::SHA1.hexdigest(name.to_s)
			end
	end
end
