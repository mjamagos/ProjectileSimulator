include(joinpath(@__DIR__, "ProjectilePhysics.jl"))
using .ProjectilePhysics
using Printf

function ask(prompt)
    print(prompt)
    flush(stdout)
    eof(stdin) && throw(EOFError())
    return strip(readline())
end

function read_number(prompt, valid, error_message)
    while true
        value = tryparse(Float64, ask(prompt))
        if value !== nothing && isfinite(value) && valid(value)
            return value
        end
        println(error_message)
    end
end

function ask_yes_no(prompt)
    while true
        answer = lowercase(ask(prompt))
        answer in ("y", "yes") && return true
        answer in ("n", "no") && return false
        println("Please enter y or n.")
    end
end

function display_results(result)
    println("\nRESULTS")
    @printf("Flight time:         %.4f seconds\n", result.flight_time)
    @printf("Maximum height:      %.4f meters\n", result.max_height)
    @printf("Horizontal distance: %.4f meters\n", result.distance)

    println("\nPOSITION TABLE")
    @printf("%12s %16s %16s\n", "Time (s)", "Distance (m)", "Height (m)")
    for point in result.positions
        @printf("%12.4f %16.4f %16.4f\n", point.time, point.x, point.y)
    end
end

function export_csv(result)
    # Numbered filenames preserve previous simulation results.
    folder = joinpath(@__DIR__, "results")
    mkpath(folder)
    number = 1
    path = joinpath(folder, "trajectory_$(number).csv")
    while ispath(path)
        number += 1
        path = joinpath(folder, "trajectory_$(number).csv")
    end

    open(path, "w") do file
        println(file, "time_seconds,distance_meters,height_meters")
        for point in result.positions
            println(file, "$(point.time),$(point.x),$(point.y)")
        end
    end
    return path
end

function main()
    println("PROJECTILE MOTION SIMULATOR")
    println("Gravity: 9.81 m/s^2. No air resistance.")
    println("Launch and landing are at the same height.\n")

    while true
        speed = read_number("Initial speed (m/s): ", x -> x > 0,
                            "Enter a positive, finite number.")
        angle = read_number("Launch angle (degrees): ", x -> 0 < x <= 90,
                            "Enter an angle greater than 0 and at most 90.")

        result = try
            simulate(speed, angle)
        catch error
            error isa ArgumentError || rethrow()
            println(sprint(showerror, error))
            continue
        end
        display_results(result)

        if ask_yes_no("\nExport the position table to CSV? (y/n): ")
            try
                path = export_csv(result)
                println("Saved: ", path)
            catch error
                error isa InterruptException && rethrow()
                println("Could not save CSV: ", sprint(showerror, error))
            end
        end

        ask_yes_no("\nRun another simulation? (y/n): ") || break
        println()
    end
    println("Goodbye!")
end

if abspath(PROGRAM_FILE) == @__FILE__
    try
        main()
    catch error
        if error isa EOFError || error isa InterruptException
            println("\nSimulator closed.")
        else
            rethrow()
        end
    end
end
