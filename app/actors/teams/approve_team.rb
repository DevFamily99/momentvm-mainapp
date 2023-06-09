module Teams
  # Approve a signed up team and generate demo data
  class ApproveTeam < Actor
    play CreateAdminUser, CreateAdminRole,
         SetupFolders, GenerateTemplates, GenerateCountryGroups, CreateTeamOnTranslationService,
         GenerateDemoPage, SetTeamAsApproved, SendApprovedMail
  end
end
