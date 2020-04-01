module Profiles

using Pkg.TOML
import Base.Dict

struct Profile
    name::AbstractString
    date::Union{AbstractString,Nothing}
    about::Union{AbstractString,Nothing}
    homepage::Union{AbstractString,Nothing}
    email::Union{AbstractString,Nothing}
    facebook::Union{AbstractString,Nothing}
    twitter::Union{AbstractString,Nothing}
    github::Union{AbstractString,Nothing}
end

function Dict(profile::Profile)
    dict = Dict()

    isnothing(profile.name) || (dict["name"] = profile.name)
    isnothing(profile.date) || (dict["date"] = profile.date)
    isnothing(profile.about) || (dict["about"] = profile.about)
    isnothing(profile.homepage) || (dict["homepage"] = profile.homepage)
    isnothing(profile.email) || (dict["email"] = profile.email)
    isnothing(profile.facebook) || (dict["facebook"] = profile.facebook)    
    isnothing(profile.twitter) || (dict["twitter"] = profile.twitter)    
    isnothing(profile.github) || (dict["github"] = profile.github)    

    return dict
end

### I could use this for the tests with something like Profile(Dict("name"=>"account1"))
function Profile(dict::Dict)
    
    haskey(dict,"name") ? (name=dict["name"]) : (name=nothing)
    haskey(dict,"date") ? (date=dict["date"]) : (date=nothing)
    haskey(dict,"about") ? (about=dict["about"]) : (about=nothing)
    haskey(dict,"homepage") ? (homepage=dict["hompage"]) : (homepage=nothing)
    haskey(dict,"email") ? (email=dict["email"]) : (email=nothing)
    haskey(dict,"facebook") ? (facebook=dict["facebook"]) : (facebook=nothing)
    haskey(dict,"twitter") ? (twitter=dict["twitter"]) : (twitter=nothing)
    haskey(dict,"github") ? (twitter=dict["github"]) : (github=nothing)

    # One may also add membership of each deme as part of the profile additionally with signatures in a envelope form.
    
    return Profile(name,date,about,homepage,email,facebook,twitter,github)
end

function save(fname::AbstractString,profile::Profile)
    mkpath(dirname(fname))
    dict = Dict(profile)
    open(fname, "w") do io
        TOML.print(io, dict)
    end
end

save(profile::Profile) = save(CONFIG_DIR * "/Profile.toml",profile)

function Profile(fname::AbstractString)
    @assert isfile(fname) "No profile file found"
    dict = TOML.parsefile(fname)
    return Profile(dict)
end

Profile() = Profile(CONFIG_DIR * "/Profile.toml")


end
