# Add a short sleep to reduce the chance of hitting GitHub rate limits
function with_delay(f::F) where {F<:Function}
    sleep(1)
    return f()
end
