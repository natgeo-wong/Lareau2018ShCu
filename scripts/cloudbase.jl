using DrWatson
@quickactivate "Lareau2018ShCu"

using ARMLive

ads = ARMDataset(
    stream="bnfdlfptM1.b1",path=datadir(),
    start=Date(2010,1,1),stop=Date(2026,5,31)
)

dtvec = ads.start : Day(1) : ads.stop; ndt = length(dtvec)
bs  = zeros(320,86400)
i   = zeros(320,86400)
cbh = zeros(86400, ndt)
t   = zeros(86400, ndt)

for (idt, dt) in enumerate(dtvec)
    ds = read(ads,dt,throw=false)
    if !isnothing(ds)
        tt = ds["time"].var[:]; nt = length(tt)
        t[1:nt,idt] .= tt .+ (idt - 1) * 86400
        bs[:,1:nt] = nomissing(ds["bs"][:,:],NaN)
        i[:,1:nt]  = nomissing(ds["i"][:,:],NaN)
        bs[((i.-1).<0.005).|(bs.<=0)] .= NaN;
        logbs = log10.(bs)

        for it = 1 : nt

            ilogbs = @views logbs[:,it]
            iz = findfirst(ilogbs .> -4.6)

            if !isnothing(iz)
                cbh[it, idt] = iz
            end

        end

    end
end

