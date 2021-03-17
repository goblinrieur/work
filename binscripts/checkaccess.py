import ldappy
import argparse

group="SALES-DLG"

def checkNAVBLUEaccess(basegroup=group,showall=False):
   if not showall:
       print "These users are not members of a NAVBLUETECH access group:"
   args = ldappy.getargs(["--name",basegroup,"-m","-b","DC=ykf,DC=navtech,DC=corp"])
   di = ldappy.getdomaininfo(args)
   members = di[0][1]['member']
   for member in members:
      membership = ldappy.getInfoforMember(member,fields=["memberOf"])
      groups = [ group.split('=')[1].split(',')[0] for group in membership[0][1]['memberOf'] ]
      shortname = member.split('=')[1].split(',')[0]
      if "YKF_Users_to_be_deleted" not in member:
      #print member
        if 'NAVBLUETECH_EXTERNAL' in groups or 'NAVBLUETECH_INTERNAL' in groups:
           if showall:
              print shortname
        else:
           if showall:
              print "No Access:"+shortname
           else:
              print shortname

def configure_argparse():
   argparser = argparse.ArgumentParser(description='Show ldap infomation for user - default is group membership')

   argparser.add_argument("group", help='verify NAVBLUETECH access for all members of this group')
   argparser.add_argument("-f","--full", help='show all users',action="store_true")
   return argparser

def main():
   argparser = configure_argparse()
   myargs=argparser.parse_args()
   print "Checking "+myargs.group
   checkNAVBLUEaccess(myargs.group,myargs.full)
   return

if __name__ == "__main__":
   main()
