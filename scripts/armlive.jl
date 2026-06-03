using DrWatson
@quickactivate "Lareau2018ShCu"

using ARMLive

ads = ARMDataset(
    stream="sgpdlfptC1.b1",path=datadir(),
    start=Date(2011,7,19),stop=Date(2011,7,21)
)
download(ads)