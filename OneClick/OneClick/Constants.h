//
//  Constants.h
//  OneClick
//
//  Created by Ignacio Dominguez on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#ifdef DEBUG
#define VCLURL @"https://152.46.19.9/index.php?mode=xmlrpccall"
#else
#define VCLURL @"https://vcl.ncsu.edu/scheduling/index.php?mode=xmlrpccall"
#endif


#define keychainCredentialKey @"VCLOneClickCredentials"

#define SSHAppKey @"SSHApp"
#define RDPAppKey @"RDPApp"