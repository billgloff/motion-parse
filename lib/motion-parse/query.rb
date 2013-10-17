module MotionParse
  class Query
    attr_reader :owner

    def initialize(owner)
      @owner = owner
      @pf_query = PFQuery.alloc.initWithClassName(@owner.name)
    end

    def where(options = nil)
      options ? equal(options) : self
    end

    def equal(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), equalTo:value
      end
      self
    end
    alias eq equal

    def not_equal(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), notEqualTo:value
      end
      self
    end
    alias ne not_equal

    def less_than(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), lessThan:value
      end
      self
    end
    alias lt less_than

    def greater_than(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), greaterThan:value
      end
      self
    end
    alias gt greater_than

    def less_than_or_equal(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), lessThanOrEqualTo:value
      end
      self
    end
    alias lte less_than_or_equal

    def greater_than_or_equal(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), greaterThanOrEqualTo:value
      end
      self
    end
    alias gte greater_than_or_equal

    def contained_in(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), containedIn:value
      end
      self
    end

    def not_contained_in(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), notContainedIn:value
      end
      self
    end

    def contains(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), containsAllObjectsInArray:value
      end
      self
    end

    def includeKey(value)
      @pf_query.includeKey(value)
      self
    end

    def matches(options, modifiers = nil)
      options.each do |key, value|
        if modifiers
          @pf_query.whereKey resolve_alias(key), matchesRegex:value, modifiers:modifiers
        else
          @pf_query.whereKey resolve_alias(key), matchesRegex:value
        end
      end
      self
    end

    def contains_string(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), containsString:value
      end
      self
    end

    def has_prefix(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), hasPrefix:value
      end
      self
    end

    def has_suffix(options)
      options.each do |key, value|
        @pf_query.whereKey resolve_alias(key), hasSuffix:value
      end
      self
    end

    def find(&block)
      if block
        query = self
        @pf_query.find_in_background do |objects, error|
          objects = objects.map { |obj| query.owner.new(obj) } if objects
          block.call(objects, error)
        end
      else
        @pf_query.findObjects.map { |obj| @owner.new(obj) }
      end
    end

    def first(&block)
      if block
        query = self
        @pf_query.first_in_background do |object, error|
          block.call(query.owner.new(object), error)
        end
      else
        object = @pf_query.getFirstObject
        object ? @owner.new(object) : nil
      end
    end

    def count(&block)
      if block
        @pf_query.count_in_background do |result, error|
          block.call(result, error)
        end
      else
        @pf_query.countObjects
      end
    end

    def limit(num)
      @pf_query.limit = num
      self
    end

    def offset(num)
      @pf_query.skip = num
      self
    end
    alias skip offset

    def order(spec)
      spec.each do |field, dir|
        if @ordered
          if dir == :asc
            @pf_query.addAscendingOrder(field)
          else
            @pf_query.addDescendingOrder(field)
          end
        else
          if dir == :asc
            @pf_query.orderByAscending(field)
          else
            @pf_query.orderByDescending(field)
          end
          @ordered = true
        end
      end
      self
    end

  private
    def resolve_alias(key)
      if resolved = @owner.attribute_aliases[key]
        resolved
      else
        key
      end
    end
  end
end
