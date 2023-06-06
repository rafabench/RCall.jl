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

function locate_libR(Rhome)
    @static if Sys.iswindows()
        libR = joinpath(Rhome, "bin", Sys.WORD_SIZE==64 ? "x64" : "i386", "R.dll")
    else
        libR = joinpath(Rhome, "lib", "libR.$(Libdl.dlext)")
    end
    validate_libR(libR)
    return libR
end

function validate_libR(libR)
    if !isfile(libR)
        error("Could not find library $libR. Make sure that R shared library exists.")
    end
    # Issue #143
    # On linux, sometimes libraries linked from libR (e.g. libRblas.so) won't open unless LD_LIBRARY_PATH is set correctly.
    libptr = try
        Libdl.dlopen(libR)
    catch er
        Base.with_output_color(:red, stderr) do io
            print(io, "ERROR: ")
            showerror(io, er)
            println(io)
        end
        @static if Sys.iswindows()
            error("Try adding $(dirname(libR)) to the \"PATH\" environmental variable and restarting Julia.")
        else
            error("Try adding $(dirname(libR)) to the \"LD_LIBRARY_PATH\" environmental variable and restarting Julia.")
        end
    end
    # R_tryCatchError is only available on v3.4.0 or later.
    if Libdl.dlsym_e(libptr, "R_tryCatchError") == C_NULL
        error("R library $libR appears to be too old. RCall.jl requires R 3.4.0 or later.")
    end
    Libdl.dlclose(libptr)
    return true
end

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
