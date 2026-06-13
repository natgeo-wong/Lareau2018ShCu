using DrWatson
@quickactivate "Lareau2018ShCu"

using ARMLive
using StatsBase

ads = ARMDataset(
    stream="bnfdlfptM1.b1",path="/Volumes/TmPi",
    start=Date(2025,5,1),stop=Date(2025,7,31)
)

dtvec = ads.start : Day(1) : ads.stop; ndt = length(dtvec)
bsbin = -8:0.01:0; nbsbin = length(bsbin)-1; bscount = zeros(Int,nbsbin)

for (idt, dt) in enumerate(dtvec)
    dsvec = read(ads,dt,throw=false,returnvec=true)
    @info "$(now()) - Reading data for $dt"; flush(stderr)
    if !isnothing(dsvec)
        for (ids, ds) in enumerate(dsvec)
            bs = nomissing(ds["attenuated_backscatter"][:],NaN)
            ii = nomissing(ds["intensity"][:],NaN)
            close(ds)
            bs[(ii.<=0.01).|(bs.<=0)] .= NaN
            logbs = log10.(bs)
            bscount[:] += fit(Histogram, logbs, bsbin).weights
        end
    end
end

fnc = datadir("$(ads.stream)-binbackscatter-$(Dates.format(ads.start,dateformat"yyyymmdd"))-$(Dates.format(ads.stop,dateformat"yyyymmdd")).nc")
if isfile(fnc); rm(fnc,force=true) end
ds = NCDataset(fnc,"c")

defDim(ds,"bins",nbsbin)

ncbin  = defVar(ds,"bins",Float64,("bins",))
nccnt  = defVar(ds,"count",Int64,("bins",))

ncbin[:] = collect(bsbin[1:(end-1)].+bsbin[2:end])./2
nccnt[:] = bscount

close(ds)
