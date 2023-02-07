import JuliaFormatter

const dotformat_directory = @__DIR__
const root_directory = dirname(dotformat_directory)

function get_command()
    if length(ARGS) != 1
        msg = "Usage: julia $(basename(@__FILE__)) [command]"
        println(stderr, msg)
        throw(ErrorException("Invalid usage"))
    end
    command = ARGS |> only |> strip |> String
    if command == "fix"
        return :fix
    elseif command == "check"
        return :check
    else
        allowed_commands = ("fix", "nothrow")
        msg1 = "Invalid command: $(command)"
        msg2 = "Allowed commands: $(join(allowed_commands, ", "))"
        println(stderr, msg1)
        println(stderr, msg2)
        throw(ErrorException("Invalid usage"))
    end
    return command
end

function format(command::Symbol)
    directory_to_format = root_directory
    style = JuliaFormatter.DefaultStyle()
    format_markdown = true
    verbose = true
    if command == :check
        overwrite = false
    else
        overwrite = true
    end
    already_formatted = JuliaFormatter.format(
        directory_to_format,
        style;
        format_markdown,
        overwrite,
        verbose,
    )
    if !already_formatted && (command == :check)
        msg = "Some formatting changes were applied"
        throw(ErrorException(msg))
    end
    return nothing
end

function main()
    command = get_command()
    format(command)
    return nothing
end

main()
