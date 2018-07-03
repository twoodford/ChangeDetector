//
//  flock.h
//  changetrackupdater
//
//  Created by Tim on 7/2/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

#ifndef flock_h
#define flock_h

#include <sys/file.h>

extern int check_lock_file(int fd);
extern void unlock_file(int fd);

#endif /* flock_h */
