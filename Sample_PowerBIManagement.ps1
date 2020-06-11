Connect-PowerBIServiceAccount

# View Workspaces and Details
Invoke-PowerBIRestMethod -Url 'groups' -Method Get


# View Dataset and Details
Invoke-PowerBIRestMethod -Url 'datasets' -Method Get

