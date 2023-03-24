if Auctionator.Config.Get(Auctionator.Config.Options.COLLECTIONATOR_SUMMARY) then
  Auctionator.Tabs.Register( {
    name = "Collecting(s)",
    textLabel = COLLECTIONATOR_L_TAB_SUMMARY,
    tabTemplate = "CollectionatorSummaryTabFrameTemplate",
    tabHeader = COLLECTIONATOR_L_TAB_SUMMARY_HEADER,
    tabFrameName = "CollectionatorSummaryTabFrame",
    tabOrder = 5,
  })
end
