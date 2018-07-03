//
//  flock.c
//  changetrackupdater
//
//  Created by Tim on 7/2/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

#include "flock.h"

int check_lock_file(int fd) {
    return flock(fd, LOCK_EX|LOCK_NB);
}

void unlock_file(int fd) {
    flock(fd, LOCK_UN);
}
