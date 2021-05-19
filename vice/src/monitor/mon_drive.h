/*
 * mon_drive.h - The VICE built-in monitor drive functions.
 *
 * Written by
 *  Andreas Boose <viceteam@t-online.de>
 *
 * This file is part of VICE, the Versatile Commodore Emulator.
 * See README for copyright notice.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 *  02111-1307  USA.
 *
 */

#ifndef VICE_MON_DRIVE_H
#define VICE_MON_DRIVE_H

#include "monitor.h"

extern void mon_drive_block_cmd(int op, int track, int sector, MON_ADDR addr);
extern void mon_drive_execute_disk_cmd(char *cmd);
extern void mon_drive_list(int drive_number);

/* FIXME: this function should perhaps live elsewhere */
extern int mon_drive_is_fsdevice(int drive_unit);
/* FIXME: this function should perhaps live elsewhere */
extern const char *mon_drive_get_fsdevice_path(int drive_unit);

#endif
