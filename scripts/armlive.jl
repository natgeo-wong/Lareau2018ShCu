using DrWatson
@quickactivate "Lareau2018ShCu"

using ARMLive

yr = parse(Int,ARGS[1])
for mo = 1 : 12
    ads = ARMDataset(
        stream="bnfdlfptM1.b1",path=datadir(),
        start=Date(yr,mo,1),stop=Date(yr,mo,daysinmonth(yr,mo))
    )
    download(ads,interactive=false)
end