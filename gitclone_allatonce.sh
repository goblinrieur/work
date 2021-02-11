#    Set CNTX=users and NAME=yourusername, to download all your repositories.
#    Set CNTX=orgs and NAME=yourorgname, to download all repositories of your organization.
#    CNTX={users|orgs}; NAME={username|orgname}; PAGE=1
#    got solution from : https://stackoverflow.com/questions/19576742/how-to-clone-all-repos-at-once-from-github

CNTX={orgs}; NAME={Artilect-FabTronic}; PAGE=1
curl "https://api.github.com/$CNTX/$NAME/repos?page=$PAGE&per_page=100" |
    grep -e 'git_url*' | cut -d \" -f 4 | xargs -L1 git clone
