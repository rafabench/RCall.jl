__precompile__()
module RCall

using Requires
using Dates
using Libdl
using Random
using REPL
if VERSION ≤ v"1.1.1"
   using Missings
end
using CategoricalArrays
using DataFrames
using StatsModels

import DataStructures: OrderedDict

import Base: eltype, convert, isascii,
    names, length, size, getindex, setindex!,
    show, showerror, write
import Base.Iterators: iterate, IteratorSize, IteratorEltype, Pairs, pairs

export RObject,
   Sxp, NilSxp, StrSxp, CharSxp, LglSxp, IntSxp, RealSxp, CplxSxp,
   ListSxp, VecSxp, EnvSxp, LangSxp, ClosSxp, S4Sxp,
   getattrib, setattrib!, getnames, setnames!, getclass, setclass!, attributes,
   globalEnv,
   isnull, isna, anyna,
   robject, rcopy, rparse, rprint, reval, rcall, rlang,
   rimport, @rimport, @rlibrary, @rput, @rget, @var_str, @R_str

if !haskey(ENV, "IGNORE_RHOME")
    const depfile = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
    if isfile(depfile)
        include(depfile)
    else
        error("RCall not properly installed. Please run Pkg.build(\"RCall\")")
    end
else
    if !haskey(ENV, "R_HOME")
        error("R_HOME not found.")
        if !isdir(get(ENV, "R_HOME", ""))
            error("Path to R folder not found.")
        end
    end
    const Rhome = get(ENV, "R_HOME", "")
    const libR = locate_libR(Rhome)
end

include("types.jl")
include("Const.jl")
include("methods.jl")
include("convert/base.jl")
include("convert/missing.jl")
include("convert/categorical.jl")
include("convert/datetime.jl")
include("convert/dataframe.jl")
include("convert/formula.jl")
include("convert/namedtuple.jl")

include("convert/default.jl")
include("eventloop.jl")
include("eval.jl")
include("language.jl")
include("io.jl")
include("callback.jl")
include("namespaces.jl")
include("render.jl")
include("macros.jl")
include("operators.jl")
include("RPrompt.jl")
include("ijulia.jl")
include("setup.jl")
include("deprecated.jl")

end # module
