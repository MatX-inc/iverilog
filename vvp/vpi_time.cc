/*
 * Copyright (c) 2001-2002 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */
#ifdef HAVE_CVS_IDENT
#ident "$Id: vpi_time.cc,v 1.9 2002/12/21 00:55:58 steve Exp $"
#endif

# include  "vpi_priv.h"
# include  "schedule.h"
# include  <stdio.h>
# include  <assert.h>

/*
 * The $time system function is supported in VPI contexts (i.e. an
 * argument to a system task/function) as a magical time variable. The
 * VPI sees it as a vpiTimeVar object, but reads from it get the
 * current value instead of some assigned value.
 */

/*
 * vpi_time_precision is the precision of the simulation clock. It is
 * set by the :vpi_time_precision directive in the vvp source file.
 */
static int vpi_time_precision = 0;

void vpip_time_to_timestruct(struct t_vpi_time*ts, vvp_time64_t ti)
{
      ts->low  = ti & 0xFFFFFFFF;
      ts->high = (ti >> 32) & 0xFFFFFFFF;
}

vvp_time64_t vpip_timestruct_to_time(const struct t_vpi_time*ts)
{
      vvp_time64_t ti = ts->high;
      ti <<= 32;
      ti += ts->low & 0xffffffff;
      return ti;
}


static int timevar_get(int code, vpiHandle ref)
{
      switch (code) {
          case vpiSize:
	      return 64;

          case vpiSigned:
	      return 0;

	  default:
	      fprintf(stderr, "Code: %d\n", code);
	      assert(0);
	      return 0;
      }
}

static void timevar_get_value(vpiHandle ref, s_vpi_value*vp)
{
      static char buf_obj[128];

	/* Keep a persistent structure for passing time values back to
	   the caller. */
      static struct t_vpi_time time_value;

      struct __vpiSystemTime*rfp = reinterpret_cast<struct __vpiSystemTime*>(ref);
      unsigned long x, num_bits;
      vvp_time64_t simtime = schedule_simtime();
      int units = rfp->scope->time_units;
      while (units > vpi_time_precision) {
	    simtime /= 10;
	    units -= 1;
      }

      switch (vp->format) {
	  case vpiObjTypeVal:
	  case vpiTimeVal:
	    vp->value.time = &time_value;
	    vp->value.time->type = vpiSimTime;
	    vpip_time_to_timestruct(vp->value.time, simtime);
	    vp->format = vpiTimeVal;
	    break;

	  case vpiBinStrVal:
	    x = simtime;
	    num_bits = 8 * sizeof(unsigned long);

	    buf_obj[num_bits] = 0;
	    for (unsigned i = 1; i <= num_bits; i++) {
	      buf_obj[num_bits-i] = x  & 1 ? '1' : '0';
	      x = x >> 1;
	    }

	    vp->value.str = buf_obj;
	    break;

	  case vpiDecStrVal:
	    sprintf(buf_obj, "%lu", simtime);
	    vp->value.str = buf_obj;
	    break;

	  case vpiOctStrVal:
	    sprintf(buf_obj, "%lo", simtime);
	    vp->value.str = buf_obj;
	    break;

	  case vpiHexStrVal:
	    sprintf(buf_obj, "%lx", simtime);
	    vp->value.str = buf_obj;
	    break;

	  default:
	    fprintf(stderr, "vpi_time: unknown format: %d\n", vp->format);
	    assert(0);
      }
}

static const struct __vpirt vpip_system_time_rt = {
      vpiTimeVar,
      timevar_get,
      0,
      timevar_get_value,
      0,
      0,
      0
};


vpiHandle vpip_sim_time(struct __vpiScope*scope)
{
      scope->scoped_time.base.vpi_type = &vpip_system_time_rt;
      scope->scoped_time.scope = scope;
      return &scope->scoped_time.base;
}

int vpip_get_time_precision(void)
{
      return vpi_time_precision;
}

void vpip_set_time_precision(int pre)
{
      vpi_time_precision = pre;
}


/*
 * $Log: vpi_time.cc,v $
 * Revision 1.9  2002/12/21 00:55:58  steve
 *  The $time system task returns the integer time
 *  scaled to the local units. Change the internal
 *  implementation of vpiSystemTime the $time functions
 *  to properly account for this. Also add $simtime
 *  to get the simulation time.
 *
 * Revision 1.8  2002/08/12 01:35:09  steve
 *  conditional ident string using autoconfig.
 *
 * Revision 1.7  2002/04/20 04:33:23  steve
 *  Support specified times in cbReadOnlySync, and
 *  add support for cbReadWriteSync.
 *  Keep simulation time in a 64bit number.
 *
 * Revision 1.6  2002/01/15 03:06:29  steve
 *  Support vpiSize and vpiSigned for time objects.
 *
 * Revision 1.5  2001/10/15 02:55:03  steve
 *  sign warning.
 *
 * Revision 1.4  2001/08/16 03:29:31  steve
 *  Support various other string formats for time.
 *
 * Revision 1.3  2001/06/30 23:03:17  steve
 *  support fast programming by only writing the bits
 *  that are listed in the input file.
 *
 * Revision 1.2  2001/04/03 03:46:14  steve
 *  VPI access time as a decimal string, and
 *  stub vpi access to the scopes.
 *
 * Revision 1.1  2001/03/31 19:00:44  steve
 *  Add VPI support for the simulation time.
 *
 */

