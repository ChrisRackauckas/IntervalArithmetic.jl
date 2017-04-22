# This file is part of the IntervalArithmetic.jl package; MIT licensed

# The order in which files are included is important,
# since certain things need to be defined before others use them

## Interval type

<<<<<<< HEAD
abstract type AbstractInterval{T} <: Real end
=======
const validity_check = false

abstract AbstractInterval <: Real
>>>>>>> Add boolean to add or remove validity check on Interval

struct Interval{T<:Real} <: AbstractInterval{T}
    lo :: T
    hi :: T

    function Interval(a::Real, b::Real)
        if validity_check
            if isvalid(a, b)
                new(a, b)
            else
                throw(ArgumentError("Must have a ≤ b to construct interval(a, b)."))
            end
        end

        new(a, b)

    end
end



## Outer constructors

Interval(a::T, b::T) where T<:Real = Interval{T}(a, b)
Interval(a::T) where T<:Real = Interval(a, a)
Interval(a::Tuple) = Interval(a...)
Interval(a::T, b::S) where {T<:Real, S<:Real} = Interval(promote(a,b)...)

## Concrete constructors for Interval, to effectively deal only with Float64,
# BigFloat or Rational{Integer} intervals.
Interval(a::T, b::T) where T<:Integer = Interval(float(a), float(b))
Interval(a::T, b::T) where T<:Irrational = Interval(float(a), float(b))

eltype(x::Interval{T}) where T<:Real = T

Interval(x::Interval) = x
Interval(x::Complex) = Interval(real(x)) + im*Interval(imag(x))

Interval{T}(x) where T = Interval(convert(T, x))

Interval{T}(x::Interval) where T = convert(Interval{T}, x)

"""
    isvalid(a::Real, b::Real)

Check if `(a, b)` constitute a valid interval
"""
function isvalid(a::Real, b::Real)
    if isnan(a) || isnan(b)
        return true
    end

    if a > b
        if isinf(a) && isinf(b)
            return true  # empty interval = [∞,-∞]
        else
            return false
        end
    end

    return true
end

function interval(a::Real, b::Real)
    if !isvalid(a, b)
        throw(ArgumentError("Must have a ≤ b to construct interval(a, b)."))
    end

    return Interval(a, b)
end


## Include files
include("special.jl")
include("macros.jl")
include("rounding_macros.jl")
include("rounding.jl")
include("conversion.jl")
include("precision.jl")
include("set_operations.jl")
include("arithmetic.jl")
include("functions.jl")
include("trigonometric.jl")
include("hyperbolic.jl")


# Syntax for intervals

# a..b = Interval(convert(Interval, a).lo, convert(Interval, b).hi)

..(a::Integer, b::Integer) = Interval(a, b)
..(a::Integer, b::Real) = Interval(a, nextfloat(float(b)))
..(a::Real, b::Integer) = Interval(prevfloat(float(a)), b)

..(a::Real, b::Real) = Interval(prevfloat(float(a)), nextfloat(float(b)))

macro I_str(ex)  # I"[3,4]"
    @interval(ex)
end

a ± b = (a-b)..(a+b)
