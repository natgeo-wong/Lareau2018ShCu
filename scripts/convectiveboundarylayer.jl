using DrWatson
@quickactivate "Lareau2018ShCu"

using ARMLive

ads = ARMDataset(
    stream="sgpdlprofwstats4newsC1.b1",path=datadir(),
    start=Date(2010,10,1),stop=Date(2026,5,31)
)

dtvec = ads.start : Day(1) : ads.stop; ndt = length(dtvec)
cblh = zeros(144,ndt) * NaN

for (idt, dt) in enumerate(dtvec)
    @info "$(now()) - Reading data for $dt"; flush(stderr)
    ds = read(ads,dt,throw=false)
    if !isnothing(dsvec)
        z   = ds["height"][:]
	    wσ  = nomissing(ds["w_variance"][:,:],NaN)
        close(ds)
        for it = 1 : 144
            iz = findfirst(wσ[z.>50,it].<0.1)
            cblh[it,idt] = !isnothing(iz) ? z[z.>50][iz] : NaN
        end
    end
end

fnc = datadir("$(ads.stream)-cblh-$(Dates.format(ads.start,dateformat"yyyymmdd"))-$(Dates.format(ads.stop,dateformat"yyyymmdd")).nc")
if isfile(fnc); rm(fnc,force=true) end
ds = NCDataset(fnc,"c")

defDim(ds,"time",length(t))

nct  = defVar(ds,"time",Float64,("time",),attrib=Dict(
    "units"     => "minutes since $(ads.start) 00:00:00.0",
    "long_name" => "time",
    "calendar"  => "gregorian",
))

nccblh  = defVar(ds,"cblh",Float64,("time",),attrib=Dict(
    "description"   => "Convective Boundary Layer Height",
    "standard_name" => "convective_boundary_layer_height",
    "units"         => "m"
))

nct.var[:] .= collect(0.5 : length(cblh)) * 10
nccblh[:] .= cblh[:]

close(ds)