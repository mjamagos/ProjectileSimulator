module ProjectilePhysics

export simulate

const GRAVITY = 9.81

function simulate(speed, angle)
    if !isfinite(speed) || speed <= 0
        throw(ArgumentError("Speed must be a positive, finite number."))
    end
    if !isfinite(angle) || !(0 < angle <= 90)
        throw(ArgumentError("Angle must be greater than 0 and at most 90 degrees."))
    end

    vx = speed * cosd(angle)
    vy = speed * sind(angle)

    flight_time = 2 * (vy / GRAVITY)
    max_height = (vy / 2) * (vy / GRAVITY)
    distance = vx * flight_time

    if !all(isfinite, (flight_time, max_height, distance)) || flight_time <= 0
        throw(ArgumentError("Speed is outside the supported numerical range."))
    end

    # Eleven samples include launch, the peak, and landing.
    times = range(0.0, flight_time; length=11)
    positions = [
        (time=t, x=vx * t, y=max(0.0, (GRAVITY / 2) * t * (flight_time - t)))
        for t in times
    ]

    return (; flight_time, max_height, distance, positions)
end

end
