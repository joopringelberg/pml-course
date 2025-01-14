-- Firstname Lastname. mm/dd/yyyy.
domain model://joopringelberg.nl#Boodschappenlijst
  use bl for model://joopringelberg.nl#Boodschappenlijst

  -------------------------------------------------------------------------------
  ---- PREAMBULE
  -------------------------------------------------------------------------------
  state ReadyToInstall = exists sys:PerspectivesSystem$Installer
    on entry
      do for sys:PerspectivesSystem$Installer
        letA
          app <- create context BoodschappenlijstenBeheer
          start <- create role StartContexts in sys:MySystem
        in
          bind_ app >> extern to start
          Name = "Boodschappen lijsten" for start
  on exit
    do for sys:PerspectivesSystem$Installer
      letA
        indexedcontext <- filter sys:MySystem >> IndexedContexts with filledBy (bl:BoodschappenApp >> extern)
        startcontext <- filter sys:MySystem >> StartContexts with filledBy (bl:BoodschappenApp >> extern)
      in
        remove context indexedcontext
        remove role startcontext

  aspect user sys:PerspectivesSystem$Installer  
  -------------------------------------------------------------------------------
  ---- END OF PREAMBULE
  -------------------------------------------------------------------------------
  
  case BoodschappenlijstenBeheer
    indexed bl:BoodschappenApp
    aspect sys:RootContext
    user Beheerder = sys:SocialMe
      perspective on Boodschappenlijsten
        only (CreateAndFill, Remove)
        props (Datum) verbs (Consult, SetPropertyValue)
    context Boodschappenlijsten (relational) filledBy Boodschappenlijst
      property Datum (Date)

  case Boodschappenlijst
    external
      state AddIncoming = not exists filter bl:BoodschappenApp with filledBy origin
        perspective of Boodschapper
          perspective on extern >> binder Boodschappenlijsten
            only (Create, Fill, CreateAndFill)
        on entry
          do for Boodschapper
            bind origin to Boodschappenlijsten in bl:BoodschappenApp
    thing Boodschappen (relational)
      property Naam (String)
      property Aantal (Number)
    user Boodschapper = sys:SocialMe
      perspective on Boodschappen
        props (Naam, Aantal) verbs (Consult, SetPropertyValue)
        only (Create, Remove)
      perspective on Huisgenoten
        only (Create, Remove)
        props (FirstName, LastName) verbs (Consult)
      perspective on Contacten
        props (FirstName, LastName) verbs (Consult)
    user Huisgenoten (relational) filledBy sys:TheWorld$PerspectivesUsers
      perspective on Boodschappen
        props (Naam, Aantal) verbs (Consult, SetPropertyValue)
        only (Create, Remove)
      perspective on Boodschapper
        props (FirstName, LastName) verbs (Consult)
      perspective on Huisgenoten 
        props (FirstName, LastName) verbs (Consult)
    user Contacten = sys:TheWorld >> PerspectivesUsers