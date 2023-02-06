function map_collect_errors(f::F, collection) where {F<:Function}
    if isempty(collection)
        msg = "Collection is empty"
        throw(ErrorException(msg))
    end
    errors = []
    for element in collection
        try
            f(element)
        catch ex
            bt = catch_backtrace()
            push!(errors, (element, ex, bt))
            @error "Just now, caught the following error" element exception=(ex, bt)
        end
    end
    if isempty(errors)
        return nothing
    end
    for (element, ex, bt) in errors
        @error "Previously, caught the following error" element exception=(ex, bt)
    end
    num_errors = length(errors)
    msg = "Caught $(num_errors) error(s)"
    throw(ErrorException(msg))
end
