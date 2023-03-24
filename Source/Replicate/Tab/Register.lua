if Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_REPLICATE) then
  Auctionator.Tabs.Register( {
    name = "Collecting",
    textLabel = COLLECTIONATOR_L_TAB_REPLICATE,
    tabTemplate = "CollectionatorReplicateTabFrameTemplate",
    tabHeader = COLLECTIONATOR_L_TAB_REPLICATE_HEADER,
    tabFrameName = "CollectionatorReplicateTabFrame",
    tabOrder = 5,
  })
end
