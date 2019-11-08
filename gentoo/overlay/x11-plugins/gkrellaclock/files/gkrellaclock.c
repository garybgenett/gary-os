/* --< GKrellAclock 0.3.4 >--{ 15 Aug 2006 }--
 * Ported to GkrellM2.0
 * includes Bill Nalen's windows port.
 *
 * Author: M.R.Muthu Kumar (m_muthukumar@users.sourceforge.net)
 *
 * All the graphic routines are from - Tom Gilbert ( http://linuxbrit.co.uk/ )
 * Xclock code contributed by Stephan Bourgeois <strangelv@lycos.co.uk>
 */

#if defined(WIN32)
#include <src/gkrellm.h>
#include <src/win32-plugin.h>
#else
#include <gkrellm2/gkrellm.h>
#endif


/*
 * Make sure we have a compatible version of GKrellM
 * (Version 2.0+ is required
 */
#if !defined(GKRELLM_VERSION_MAJOR) \
     || (GKRELLM_VERSION_MAJOR < 2 )
#error This plugin requires GKrellM version >= 2.0
#endif

#include<math.h>

#define GKRELLACLOCK_VER 	"0.3.4"

#define	CONFIG_NAME	"GkrellAclock"	/* Name in the configuration window */
#define	STYLE_NAME	"GkrellAclock"	/* Theme subdirectory name */
			                /*  and gkrellmrc style name.*/ 


#define CHART_W 120
#define CHART_H 120
#define MAX_COLORS 10
#define MAX_DARK_BG_COLORS 8

#define WHITE  0
#define ORANGE 1
#define GREEN  2
#define YELLOW 3
#define CYAN   4
#define RED    5
#define GRAY   6
#define L_PINK 7
#define BROWN  8
#define BLACK  9

#define N_WHITE  "White"
#define N_ORANGE "Orange"
#define N_GREEN  "Green"
#define N_YELLOW "Yellow"
#define N_CYAN   "Cyan"
#define N_RED    "Red"
#define N_GRAY   "Gray"
#define N_L_PINK "Light Pink"

#define R_CLOCK 0
#define X_CLOCK 1

static GkrellmMonitor		*mon;
static GkrellmChart		*chart;
static GkrellmChartconfig	*chart_config=NULL;

static GtkWidget	*cycle_option,
			*bg_option,
			*sec_select_option,
			*dial_select_option,
			*clock_type_option[2];

static gchar	*color_name[] = { N_WHITE, N_ORANGE, N_GREEN, N_YELLOW, 
                                  N_CYAN, N_RED, N_GRAY, N_L_PINK };

static gint c_red[MAX_COLORS], c_green[MAX_COLORS], c_blue[MAX_COLORS];

static gint d_color, s_color, cycle, clock_type, enable_dark_bg;
static gint prev_h = -1;
static gint chart_w = CHART_W;

static gint		style_id;

struct tm  *tm;

static gint r_value[] = { 255, 255, 0  , 255, 51 , 255, 214, 255, 255, 3 };
static gint g_value[] = { 255, 165, 255, 255, 255, 0  , 214, 204, 48 , 3};
static gint b_value[] = { 255, 0  , 0  , 102, 255, 0  , 214, 255, 48 , 3};

guchar *rgbbuf;

/* Set a pixel, takes a brightness and a colour value */
static void
set_col_pixel (gint x, gint y,  guchar c,  guchar rrr,
                guchar ggg,  guchar bbb)
{
  guchar *ptr;

//  if ((((int) c) == 0) || (x < 0) || (y < 0) || (x > 59) || (y > 39))
//    return;


  ptr = rgbbuf + ( chart_w * 3 * (y)) + (3 * x);
  ptr[0] = ((double) rrr / 255 * (double) c);
  ptr[1] = ((double) ggg / 255 * (double) c);
  ptr[2] = ((double) bbb / 255 * (double) c);
}

static void
blank_buf(void)
{
  guchar *pos;
  gint x,y;

  pos = rgbbuf;
  for (y = 0; y < CHART_H; y++)
    {
      for (x = 0; x < chart_w; x++)
        {

          if ( enable_dark_bg ) { pos[0] = pos[1] = pos[2] = 0; }
          else { pos[0] = pos[1] = pos[2] = 245; 
                 d_color = BLACK;
                 s_color = BROWN;
          }
          pos += 3;
        }
    }
}

static void
aa_line (gint x1, gint y1, gint x2, gint y2, guchar b,
         guchar rr, guchar gg, guchar bb)
{
  gdouble grad, line_width, line_height, xgap, ygap, xend, yend, yf, xf,
    brightness1, brightness2, db, xm, ym;
  gint ix1, ix2, iy1, iy2, i;
  gint temp;

  guchar c1, c2;

  line_width = (x2 - x1);
  line_height = (y2 - y1);

  if (abs (line_width) > abs (line_height))
    {
      if (x1 > x2)
        {
          temp = x1;
          x1 = x2;
          x2 = temp;
          temp = y1;
          y1 = y2;
          y2 = temp;
          line_width = (x2 - x1);
          line_height = (y2 - y1);
        }

      /* This is currently broken. It is supposed to account
       * for lines that don't span more than one pixel */
      if (abs (line_width) < 0.1)
        {
          x2 = x1 + 0.5;
          x1 -= 0.5;
          grad = 0;
        }
      else
        {
          grad = line_height / line_width;
          if (line_width < 1)
            {
              xm = (x1 + x2) / 2;
              ym = (y1 + y2) / 2;

              x1 = xm - 0.5;
              x2 = xm + 0.5;
              y1 = ym - (grad / 2);
            y2 = ym + (grad / 2);

              line_width = 1;
              line_height = grad;
            }
        }

      xend = (int) x1 + 0.5;
      yend = y1 + grad * (xend - x1);

      xgap = (1 - modf (x1 + 0.5, &db));
      ix1 = (int) xend;
      iy1 = (int) yend;

      brightness1 = (1 - modf (yend, &db)) * xgap;
      brightness2 = modf (yend, &db) * xgap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix1, iy1, c1, rr, gg, bb);
      set_col_pixel (ix1, iy1 + 1, c2, rr, gg, bb);

      yf = yend + grad;

      xend = (int) (x2 + .5);
      yend = y2 + grad * (xend - x2);

      xgap = 1 - modf (x2 - .5, &db);

      ix2 = (int) xend;
      iy2 = (int) yend;

      brightness1 = (1 - modf (yend, &db)) * xgap;
      brightness2 = modf (yend, &db) * xgap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix2, iy2, c1, rr, gg, bb);
      set_col_pixel (ix2, iy2 + 1, c2, rr, gg, bb);

      for (i = ix1 + 1; i < ix2; i++)
        {
          brightness1 = (1 - modf (yf, &db));
          brightness2 = modf (yf, &db);
          c1 = (unsigned char) (brightness1 * b);
          c2 = (unsigned char) (brightness2 * b);

          set_col_pixel (i, (int) yf, c1, rr, gg, bb);
          set_col_pixel (i, (int) yf + 1, c2, rr, gg, bb);

          yf = yf + grad;
        }
    }
  else
    {
      if (y2 < y1)
        {
          temp = x1;
          x1 = x2;
          x2 = temp;
          temp = y1;
          y1 = y2;
          y2 = temp;
          line_width = (x2 - x1);
          line_height = (y2 - y1);
        }

      /* This is currently broken */
      if (abs (line_height) < 0.1)
        {
          y2 = y1 + 0.5;
          y1 -= 0.5;
          grad = 0;
        }
      else
        {
          grad = line_width / line_height;
          if (line_height < 1)
            {
              xm = (x1 + x2) / 2;
              ym = (y1 + y2) / 2;

              x1 = xm - (grad / 2);
              x2 = xm + (grad / 2);
              y1 = ym - 0.5;
              y2 = ym + 0.5;

              line_height = 1;
              line_width = grad;
            }
        }

      yend = (int) (y1 + 0.5);
      xend = x1 + grad * (yend - y1);

      ygap = (1 - modf (y1 + 0.5, &db));
      ix1 = (int) xend;
      iy1 = (int) yend;

      brightness1 = (1 - modf (xend, &db)) * ygap;
      brightness2 = modf (xend, &db) * ygap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix1, iy1, c1, rr, gg, bb);
      set_col_pixel (ix1 + 1, iy1, c2, rr, gg, bb);

      xf = xend + grad;

      yend = (int) (y2 + .5);
      xend = x2 + grad * (yend - y2);

      ygap = 1 - modf (y2 - .5, &db);

      ix2 = (int) xend;
      iy2 = (int) yend;

      brightness1 = (1 - modf (xend, &db)) * ygap;
      brightness2 = modf (xend, &db) * ygap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix2, iy2, c1, rr, gg, bb);
      set_col_pixel (ix2 + 1, iy2, c2, rr, gg, bb);
      for (i = iy1 + 1; i < iy2; i++)
        {
          brightness1 = (1 - modf (xf, &db));
          brightness2 = modf (xf, &db);

          c1 = (unsigned char) (brightness1 * b);
          c2 = (unsigned char) (brightness2 * b);

          set_col_pixel ((int) xf, i, c1, rr, gg, bb);
          set_col_pixel ((int) (xf + 1), i, c2, rr, gg, bb);

          xf += grad;
        }
    }
}


static void
Wu_line (gint x1, gint y1, gint x2, gint y2, guchar b,
         guchar rr, guchar gg, guchar bb)
{
  gdouble grad, xd, yd, xgap, ygap, xend, yend, yf, xf,
    brightness1, brightness2, db;
  gint ix1, ix2, iy1, iy2, i;
  gint temp;

  guchar c1, c2;

  xd = (x2 - x1);
  yd = (y2 - y1);

  if (abs (xd) > abs (yd))
    {
      if (x1 > x2)
        {
          temp = x1;
          x1 = x2;
          x2 = temp;
          temp = y1;
          y1 = y2;
          y2 = temp;
          xd = (x2 - x1);
          yd = (y2 - y1);
        }

      grad = yd/xd;

/* end point 1 */

      xend = (int) x1 + 0.5;
      yend = y1 + grad * (xend - x1);

      xgap = (1 - modf (x1 + 0.5, &db));
      ix1 = (int) xend;
      iy1 = (int) yend;

      brightness1 = (1 - modf (yend, &db)) * xgap;
      brightness2 = modf (yend, &db) * xgap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix1, iy1, c1, rr, gg, bb);
      set_col_pixel (ix1, iy1 + 1, c2, rr, gg, bb);

      yf = yend + grad;
      
/* end point 2 */      

      xend = (int) (x2 + .5);
      yend = y2 + grad * (xend - x2);

      xgap = 1 - modf (x2 - .5, &db);

      ix2 = (int) xend;
      iy2 = (int) yend;

      brightness1 = (1 - modf (yend, &db)) * xgap;
      brightness2 = modf (yend, &db) * xgap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix2, iy2, c1, rr, gg, bb);
      set_col_pixel (ix2, iy2 + 1, c2, rr, gg, bb);
      
/* main loop */

      for (i = ix1 + 1; i < ix2; i++)
        {
          brightness1 = (1 - modf (yf, &db));
          brightness2 = modf (yf, &db);
          c1 = (unsigned char) (brightness1 * b);
          c2 = (unsigned char) (brightness2 * b);

          set_col_pixel (i, (int) yf, c1, rr, gg, bb);
          set_col_pixel (i, (int) yf + 1, c2, rr, gg, bb);

          yf = yf + grad;
        }
    }
  else
    {
      if (y1 > y2)
        {
          temp = x1;
          x1 = x2;
          x2 = temp;
          temp = y1;
          y1 = y2;
          y2 = temp;
          xd = (x2 - x1);
          yd = (y2 - y1);
        }

      grad = xd / yd;

      yend = (int) (y1 + 0.5);
      xend = x1 + grad * (yend - y1);

      ygap = (1 - modf (y1 + 0.5, &db));
      ix1 = (int) xend;
      iy1 = (int) yend;

      brightness1 = (1 - modf (xend, &db)) * ygap;
      brightness2 = modf (xend, &db) * ygap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix1, iy1, c1, rr, gg, bb);
      set_col_pixel (ix1 + 1, iy1, c2, rr, gg, bb);

      xf = xend + grad;

      yend = (int) (y2 + .5);
      xend = x2 + grad * (yend - y2);

      ygap = 1 - modf (y2 - .5, &db);

      ix2 = (int) xend;
      iy2 = (int) yend;

      brightness1 = (1 - modf (xend, &db)) * ygap;
      brightness2 = modf (xend, &db) * ygap;

      c1 = (unsigned char) (brightness1 * b);
      c2 = (unsigned char) (brightness2 * b);

      set_col_pixel (ix2, iy2, c1, rr, gg, bb);
      set_col_pixel (ix2 + 1, iy2, c2, rr, gg, bb);
      for (i = iy1 + 1; i < iy2; i++)
        {
          brightness1 = (1 - modf (xf, &db));
          brightness2 = modf (xf, &db);

          c1 = (unsigned char) (brightness1 * b);
          c2 = (unsigned char) (brightness2 * b);

          set_col_pixel ((int) xf, i, c1, rr, gg, bb);
          set_col_pixel ((int) (xf + 1), i, c2, rr, gg, bb);

          xf += grad;
        }
    }
}

/* bresenham line algorithm */
static void 
lineBresenham(gint x0, gint y0, gint x1, gint y1, guchar b,
         guchar rr, guchar gg, guchar bb)
{
    int dy = y1 - y0;
    int dx = x1 - x0;
    int stepx, stepy;

    if (dy < 0) { dy = -dy;  stepy = -1; } else { stepy = 1; }
    if (dx < 0) { dx = -dx;  stepx = -1; } else { stepx = 1; }
    dy <<= 1;                                                  // dy is now 2*dy
    dx <<= 1;                                                  // dx is now 2*dx

    set_col_pixel ((int) x0, y0, b, rr, gg, bb);
    if (dx > dy) {
        int fraction = dy - (dx >> 1);                         // same as 2*dy - dx
        while (x0 != x1) {
            if (fraction >= 0) {
                y0 += stepy;
                fraction -= dx;                                // same as fraction -= 2*dx
            }
            x0 += stepx;
            fraction += dy;                                    // same as fraction -= 2*dy
            set_col_pixel ((int) x0, y0, b, rr, gg, bb);
        }
    } else {
        int fraction = dx - (dy >> 1);
        while (y0 != y1) {
            if (fraction >= 0) {
                x0 += stepx;
                fraction -= dy;
            }
            y0 += stepy;
            fraction += dx;
            set_col_pixel ((int) x0, y0, b, rr, gg, bb);
        }
    }
}

static void
change_dial_color(void)
{
   if ( enable_dark_bg ) {
      d_color++;
      if ( d_color >= MAX_DARK_BG_COLORS ) { d_color = 0; }
   } else { d_color = BLACK; 
            s_color = BROWN;
     }

}

static void
draw_aclock(void)
{
   gint tempX, tempY;
   gint h, m, s;
   gint half_w;


   gdouble        minutes = 20, hours = 12, seconds = 0;

   tm = gkrellm_get_current_time();

   h = tm->tm_hour;
   m = tm->tm_min;
   s = tm->tm_sec;
   hours = (double)h + ((double)m / 60) + ((double)s / 3600);
   minutes = (double)m + ((double)s / 60);
   seconds = (double)s;

   if ( cycle && prev_h != -1 && prev_h != h )
   {
     change_dial_color();
     if ( d_color == s_color ) { change_dial_color(); }
   }

   prev_h = h;

   blank_buf();

   half_w = chart_w / 2;

   if ( half_w > CHART_H ) { half_w = CHART_H; }

   set_col_pixel (half_w - 1, 0, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w, 0, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   set_col_pixel (half_w + 8, 5, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w + 14, 11, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w + 8, 34, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w + 14, 28, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   set_col_pixel (half_w - 1, 39, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w, 39, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   set_col_pixel (half_w - 15, 11, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w - 8, 5, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w - 15, 28, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w - 8, 34, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   set_col_pixel (half_w - 21, 19, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w - 21, 20, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   set_col_pixel (half_w + 19, 19, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   set_col_pixel (half_w + 19, 20, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   
   tempX = (half_w - 1) + (int)(sin((minutes * 3.14159 * 2) / 60) * 18 );
   tempY = 19 - (int)(cos((minutes * 3.14159 * 2) / 60)  * 18);
   aa_line (half_w - 1, 19, tempX, tempY, (unsigned char) 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   tempX = half_w + (int)(sin((minutes * 3.14159 * 2) / 60) * 18 );
   tempY = 20 - (int)(cos((minutes * 3.14159 * 2) / 60)  * 18);
   aa_line (half_w, 20, tempX, tempY, (unsigned char) 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   tempX = (half_w - 1) + (int)(sin((hours * 3.14159 * 2) / 12) * 12 );
   tempY = 19 - (int)(cos((hours * 3.14159 * 2) / 12)  * 12);
   aa_line (half_w - 1, 19, tempX, tempY, (unsigned char) 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   tempX = half_w + (int)(sin((hours * 3.14159 * 2) / 12) * 12 );
   tempY = 20 - (int)(cos((hours * 3.14159 * 2) / 12)  * 12);
   aa_line (half_w, 20, tempX, tempY, (unsigned char) 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   tempX = (half_w - 1) + (int)(sin((seconds * 3.14159 * 2) / 60) * 19 );
   tempY = 19 - (int)(cos((seconds * 3.14159 * 2) / 60)  * 19);
   aa_line (half_w - 1, 19, tempX, tempY, (unsigned char) 255, c_red[s_color], c_green[s_color], c_blue[s_color]);

   tempX = half_w + (int)(sin((seconds * 3.14159 * 2) / 60) * 19 );
   tempY = 20 - (int)(cos((seconds * 3.14159 * 2) / 60)  * 19);
   aa_line (half_w, 20, tempX, tempY, (unsigned char) 255, c_red[s_color], c_green[s_color], c_blue[s_color]);

}


static void
draw_xclock(void)
{
   gint  begX,  begY;
   gint  pntX,  pntY;
   gint  endX,  endY;
   gint h, m, s;
   gint half_w, half_h, i;
   gint unit_w, unit_h;
   gint full_w, full_h;

   gdouble two_pi = (atan(1) * 4) * 2;

   gdouble        minutes = 20, hours = 12, seconds = 0;
   gdouble r_hours, r_minutes, r_seconds;

   tm = gkrellm_get_current_time();

   h = tm->tm_hour;
   m = tm->tm_min;
   s = tm->tm_sec;
   hours = (double)h + ((double)m / 60) + ((double)s / 3600);
   minutes = (double)m + ((double)s / 60);
   seconds = (double)s;

   if ( cycle && prev_h != -1 && prev_h != h )
   {
     change_dial_color();
     if ( d_color == s_color ) { change_dial_color(); }
   }

   prev_h = h;

   blank_buf();

   half_w = CHART_W / 2;
   half_h = CHART_H / 2;
   full_w = half_w - (half_w / 6 / 2);
   full_h = half_h - (half_h / 6 / 2);
   unit_w = full_w / 6;
   unit_h = full_h / 6;

   // minute markers
   gdouble minuteX;
   gdouble minuteY;
   for (i = 0; i < 61; i++) {
       r_minutes = i * 6;
       minuteX = sin(r_minutes /360 * two_pi);
       minuteY = cos(r_minutes /360 * two_pi);
       if (i % 15 == 0) {
           begX = half_w + (minuteX * (full_w - unit_w));
           endX = half_w + (minuteX * full_w);
           begY = half_h + (minuteY * (full_h - unit_h));
           endY = half_h + (minuteY * full_h);
       } else if (i % 5 == 0) {
           begX = half_w + (minuteX * (full_w - (unit_w * 2/3)));
           endX = half_w + (minuteX * full_w);
           begY = half_h + (minuteY * (full_h - (unit_h * 2/3)));
           endY = half_h + (minuteY * full_h);
       } else {
           begX = half_w + (minuteX * (full_w - (unit_w * 1/4)));
           endX = half_w + (minuteX * full_w);
           begY = half_h + (minuteY * (full_h - (unit_h * 1/4)));
           endY = half_h + (minuteY * full_h);
       };
       lineBresenham(begX, begY, endX, endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   };

   // hour hand
   r_hours = hours * 30;
    endX =  sin( r_hours       /360 * two_pi) * (unit_w * 2.5);
    endY = -cos( r_hours       /360 * two_pi) * (unit_h * 2.5);
    begX =  sin((r_hours +  90)/360 * two_pi) * (unit_w / 2);
    begY = -cos((r_hours +  90)/360 * two_pi) * (unit_h / 2);
    pntX =  sin((r_hours + 180)/360 * two_pi) * (unit_w / 2);
    pntY = -cos((r_hours + 180)/360 * two_pi) * (unit_h / 2);
// normal: lineBresenham(half_w + pntX, half_h + pntY, half_w +  endX, half_h +  endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w + begX, half_h + begY, half_w +  endX, half_h +  endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w - begX, half_h - begY, half_w +  endX, half_h +  endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w + begX, half_h + begY, half_w +  pntX, half_h +  pntY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w - begX, half_h - begY, half_w +  pntX, half_h +  pntY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   // minute hand
   r_minutes = minutes * 6;
    endX =  sin( r_minutes       /360 * two_pi) * (unit_w * 4);
    endY = -cos( r_minutes       /360 * two_pi) * (unit_h * 4);
    begX =  sin((r_minutes +  90)/360 * two_pi) * (unit_w / 2);
    begY = -cos((r_minutes +  90)/360 * two_pi) * (unit_h / 2);
    pntX =  sin((r_minutes + 180)/360 * two_pi) * (unit_w / 2);
    pntY = -cos((r_minutes + 180)/360 * two_pi) * (unit_h / 2);
// normal: lineBresenham(half_w + pntX, half_h + pntY, half_w +  endX, half_h +  endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w + begX, half_h + begY, half_w +  endX, half_h +  endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w - begX, half_h - begY, half_w +  endX, half_h +  endY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w + begX, half_h + begY, half_w +  pntX, half_h +  pntY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
   lineBresenham(half_w - begX, half_h - begY, half_w +  pntX, half_h +  pntY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);

   // second hand
   gint slimX, slimY;
   r_seconds = seconds * 6;
   gdouble sml_rat = 0.5 * 6;
   slimX =  sin( r_seconds       /360 * two_pi) * (unit_w * 4);
    endX =  sin( r_seconds       /360 * two_pi) * (unit_w * 5);
   slimY = -cos( r_seconds       /360 * two_pi) * (unit_h * 4);
    endY = -cos( r_seconds       /360 * two_pi) * (unit_h * 5);
    begX =  sin((r_seconds +  90)/360 * two_pi) * (unit_w / 2);
    begY = -cos((r_seconds +  90)/360 * two_pi) * (unit_h / 2);
    pntX =  sin((r_seconds + 180)/360 * two_pi) * (unit_w / 2);
    pntY = -cos((r_seconds + 180)/360 * two_pi) * (unit_h / 2);
// normal: lineBresenham(half_w + pntX, half_h + pntY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
//   slim: lineBresenham(half_w + slimX, half_h + slimY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
//   lineBresenham(half_w + begX, half_h + begY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
//   lineBresenham(half_w - begX, half_h - begY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
//   lineBresenham(half_w + begX, half_h + begY, half_w +  pntX, half_h +  pntY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
//   lineBresenham(half_w - begX, half_h - begY, half_w +  pntX, half_h +  pntY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
   gint secX, secY;
   slimX =  sin( r_seconds           /360 * two_pi) * (unit_w * 3);
   slimY = -cos( r_seconds           /360 * two_pi) * (unit_h * 3);
    secX =  sin( r_seconds           /360 * two_pi) * (unit_w * 4.5);
    secY = -cos( r_seconds           /360 * two_pi) * (unit_h * 4.5);
    begX =  sin((r_seconds - sml_rat)/360 * two_pi) * (unit_w * 4.5);
    begY = -cos((r_seconds - sml_rat)/360 * two_pi) * (unit_h * 4.5);
    pntX =  sin((r_seconds + sml_rat)/360 * two_pi) * (unit_w * 4.5);
    pntY = -cos((r_seconds + sml_rat)/360 * two_pi) * (unit_h * 4.5);
   lineBresenham(half_w + slimX, half_h + slimY, half_w + begX, half_h + begY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
   lineBresenham(half_w + slimX, half_h + slimY, half_w + pntX, half_h + pntY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
   lineBresenham(half_w + begX, half_h + begY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
   lineBresenham(half_w + pntX, half_h + pntY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);

/*
   // seconds markers
   for (i = 0; i < seconds + 1; i++) {
        begX =  (int)(sin(i * two_pi)/60 * (full_w - (unit_w / 4)) );
        endX =  (int)(sin(i * two_pi)/60 * full_w );
        begY = -(int)(cos(i * two_pi)/60 * (full_h - (unit_h / 4)) );
        endY = -(int)(cos(i * two_pi)/60 * full_h );
       lineBresenham(half_w + begX, half_h + begY, half_w +  endX, half_h +  endY, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
   }
*/

/*
   // reference dot: center
   set_col_pixel(half_w, half_h, 255, c_red[s_color], c_green[s_color], c_blue[s_color]);
   // reference dot: second-hand mid-point
   set_col_pixel(half_w + secX, half_h + secY, 255, c_red[d_color], c_green[d_color], c_blue[d_color]);
*/
}

static void
draw_clock(void)
{
   if ( clock_type ) { draw_xclock(); }
   else { draw_aclock(); }
}

static gint
chart_expose_event(GtkWidget *widget, GdkEventExpose *ev)
{
   draw_clock();

   gdk_draw_rgb_image (widget->window, widget->style->fg_gc[GTK_STATE_NORMAL],
                      0, 0, chart_w, CHART_H,
                      GDK_RGB_DITHER_MAX, rgbbuf, chart_w * 3);
   return TRUE;
}

static void
update_plugin ( void )
{
  GdkEventExpose event;
  gint ret_val;

  g_signal_emit_by_name(GTK_OBJECT(chart->drawing_area), "expose_event", &event, &ret_val  );
}

static gint
chart_press (GtkWidget *widget, GdkEventButton *ev)
{
    if (ev->button == 1 )
    {
	  change_dial_color();

	  draw_clock();
    }
    if (ev->button == 2 )
    {
	   s_color++;
	   if ( s_color >= MAX_DARK_BG_COLORS ) { s_color = 0; }

       draw_clock();
    }

	if (ev->button == 3 )
    {
      gkrellm_open_config_window (mon);
    }


    return TRUE;
}

static void
create_plugin(GtkWidget *vbox, gint first_create)
{
	GkrellmStyle			*style;
	GkrellmTextstyle		*ts, *ts_alt;
	gint                tmp_w;


	if (first_create)
	{
	  chart = gkrellm_chart_new0();
	}  

	gkrellm_set_chart_height_default(chart, CHART_H);

	gkrellm_chart_create(vbox, mon, chart, &chart_config);

	style = gkrellm_meter_style(style_id);

	/* Each Style has two text styles.  The theme designer has picked the
	|  colors and font sizes, presumably based on knowledge of what you draw
	|  on your panel.  You just do the drawing.  You probably could assume
	|  the ts font is larger than the ts_alt font, but again you can be
	|  overridden by the theme designer.
	*/
	ts = gkrellm_meter_textstyle(style_id);
	ts_alt = gkrellm_meter_alt_textstyle(style_id);

	tmp_w = gkrellm_chart_width();
    if ( chart_w != tmp_w ) 
    {
       chart_w = tmp_w;
       rgbbuf = g_renew( guchar, rgbbuf, chart_w * CHART_H * 3 );
       blank_buf();
     }


	if (first_create)
	{	
	    g_signal_connect(GTK_OBJECT (chart->drawing_area), "expose_event",
    	        G_CALLBACK ( chart_expose_event ), NULL);

	    g_signal_connect(GTK_OBJECT(chart->drawing_area),
            "button_press_event", G_CALLBACK ( chart_press ), NULL);


	    gdk_rgb_init();
	    blank_buf();
	}  

}

#define PLUGIN_CONFIG_KEYWORD    "gkrellaclock"


static void
save_aclock_config (FILE *f)
{
    fprintf(f, "%s cycle %d\n", PLUGIN_CONFIG_KEYWORD, cycle);
    fprintf(f, "%s d_color %d\n", PLUGIN_CONFIG_KEYWORD, d_color);
    fprintf(f, "%s s_color %d\n", PLUGIN_CONFIG_KEYWORD, s_color);
    fprintf(f, "%s clock_type %d\n", PLUGIN_CONFIG_KEYWORD, clock_type);
    fprintf(f, "%s enable_dark_bg %d\n", PLUGIN_CONFIG_KEYWORD, enable_dark_bg);
}

static void
load_aclock_config (gchar *arg)
{
    gchar config[64], item[1024];
    gint n;

    n = sscanf(arg, "%s %[^\n]", config, item);
    if (n == 2)
    {
        if (strcmp(config, "cycle") == 0)
            sscanf(item, "%d\n", &(cycle));
        if (strcmp(config, "d_color") == 0)
            sscanf(item, "%d\n", &(d_color));
        if (strcmp(config, "s_color") == 0)
            sscanf(item, "%d\n", &(s_color));
        if (strcmp(config, "clock_type") == 0)
            sscanf(item, "%d\n", &(clock_type));
        if (strcmp(config, "enable_dark_bg") == 0)
            sscanf(item, "%d\n", &(enable_dark_bg));
    }

}
static gint
get_color_from_name( gchar *value )
{
  if ( ! strcmp( value, N_WHITE ) )  { return WHITE; }
  if ( ! strcmp( value, N_ORANGE ) ) { return ORANGE; }
  if ( ! strcmp( value, N_GREEN ) )  { return GREEN; }
  if ( ! strcmp( value, N_YELLOW ) ) { return YELLOW; }
  if ( ! strcmp( value, N_CYAN ) )   { return CYAN; }
  if ( ! strcmp( value, N_RED ) )    { return RED; }
  if ( ! strcmp( value, N_GRAY ) )   { return GRAY; }
  if ( ! strcmp( value, N_L_PINK ) ) { return L_PINK; }

  return WHITE;
}

static void
apply_aclock_config (void)
{
    gchar *c;

    cycle = GTK_TOGGLE_BUTTON(cycle_option)->active;

    c = gkrellm_gtk_entry_get_text(&(GTK_COMBO(dial_select_option)->entry));
	d_color = get_color_from_name( c );

    c = gkrellm_gtk_entry_get_text(&(GTK_COMBO(sec_select_option)->entry));
	s_color = get_color_from_name( c );

    enable_dark_bg = GTK_TOGGLE_BUTTON(bg_option)->active;

}



static void cycle_clicked(GtkButton* button )
{
    cycle = GTK_TOGGLE_BUTTON(cycle_option)->active;
}

static void cb_enable_dark_bg(GtkButton* button, GtkWidget *box )
{
    enable_dark_bg = GTK_TOGGLE_BUTTON(bg_option)->active;

    gtk_widget_set_sensitive(box, enable_dark_bg);
    if ( enable_dark_bg ) {
       d_color = WHITE;
       s_color = RED;
       gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(dial_select_option)->entry), color_name[d_color] );
       gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(sec_select_option)->entry), color_name[s_color] );
    }
}

static void
cb_clock_type(GtkWidget *button, gpointer data)
{
        gint    i = GPOINTER_TO_INT(data);

        if (GTK_TOGGLE_BUTTON(button)->active)
                clock_type = i;
}

static void
create_aclock_tab (GtkWidget *tab_vbox)
{
    GtkWidget *tabs, *about_label, *label, *frame, *hbox, *vbox, *ybox, *vbox1, *vbox2;
	GtkWidget *s_label, *text, *button ;

	GList *d_items = NULL;
	GList *s_items = NULL;

    gchar *about_text = NULL;

    gint i;
	static gchar *help_text[] =
    {
      N_("<h>" CONFIG_NAME " " GKRELLACLOCK_VER "\n\n" ),
      N_("<b>Simple Analog Clock \n\n" ),
      N_("Left-click will change dial color and Middle-click will change seconds \n" ),
      N_("color when Dark background is enabled.\n\n"),
      N_("Right-click opens configuration window.\n\n"),
      N_("<b> Options \n\n" ),
      N_("Clock Type - choose from Aclock and Xclock type .\n\n" ),
      N_("Enable Dark Background - toggles between dark and light background .\n\n" ),
      N_("Cycle Dial Color - when checked will change dial color every hour.\n\n" ),
      N_("Select Dial Color  from drop down .\n" ),
      N_("Select Seconds Color from drop down .\n" )
    };

    tabs = gtk_notebook_new();
    gtk_notebook_set_tab_pos(GTK_NOTEBOOK(tabs), GTK_POS_TOP);
    gtk_box_pack_start(GTK_BOX(tab_vbox), tabs, TRUE, TRUE, 0);

	/* Options */
	frame = gtk_frame_new(NULL);
    gtk_container_border_width(GTK_CONTAINER(frame), 3);

    vbox = gtk_vbox_new( FALSE, 0 );
    gtk_container_border_width(GTK_CONTAINER(vbox), 3);

    /* Clock Type */
    
     ybox = gkrellm_gtk_framed_vbox(vbox, _("Clock Type"),
                        4, FALSE, 0, 2);
        
     hbox = gtk_hbox_new(FALSE, 0);
     gtk_box_pack_start(GTK_BOX(ybox), hbox, FALSE, FALSE, 0);
    
     clock_type_option[0] = gtk_radio_button_new_with_label(NULL, _("Aclock"));
     gtk_box_pack_start(GTK_BOX(hbox), clock_type_option[0], TRUE, TRUE, 0);
     clock_type_option[1] = gtk_radio_button_new_with_label_from_widget(
                                        GTK_RADIO_BUTTON(clock_type_option[0]), _("Xclock"));
     gtk_box_pack_start(GTK_BOX(hbox), clock_type_option[1], TRUE, TRUE, 0);
    
     button = clock_type_option[clock_type];
     gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(button), TRUE);
        
     for (i = 0; i < 2; ++i) {
                g_signal_connect(G_OBJECT(clock_type_option[i]), "toggled",
                                        G_CALLBACK(cb_clock_type), GINT_TO_POINTER(i));
     }      

	/* Enable Dark Background */


    vbox2 = gtk_vbox_new( FALSE, 0 );
    gtk_container_border_width(GTK_CONTAINER(vbox2), 3);

    bg_option = gtk_check_button_new_with_label( "Enable Dark Background " );
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(bg_option), enable_dark_bg );

	gtk_widget_set_sensitive(vbox2, enable_dark_bg ? TRUE : FALSE );
    g_signal_connect(GTK_OBJECT(bg_option), "clicked", G_CALLBACK(cb_enable_dark_bg), vbox2 );

    gtk_box_pack_start(GTK_BOX(vbox), bg_option, FALSE, FALSE, 0);

	/* Cycle Dial Color */

    cycle_option = gtk_check_button_new_with_label( "Cycle Dial Color" );
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(cycle_option),
            cycle );

    g_signal_connect(GTK_OBJECT(cycle_option), "clicked", G_CALLBACK(cycle_clicked), NULL );

    gtk_box_pack_start(GTK_BOX(vbox2), cycle_option, FALSE, FALSE, 0);

	/* Dial Color */
    hbox = gtk_hbox_new(FALSE, 0);
    label = gtk_label_new("Dial Color " );

    for ( i = 0; i < MAX_DARK_BG_COLORS; i++ )
    {
      d_items = g_list_append (d_items, color_name[i] );
    }

    dial_select_option = gtk_combo_new();
    gtk_combo_set_popdown_strings (GTK_COMBO (dial_select_option), d_items);
    gtk_combo_set_value_in_list( GTK_COMBO(dial_select_option), TRUE, FALSE );
    if ( enable_dark_bg ) {
       gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(dial_select_option)->entry), color_name[d_color] );
    } else {
       gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(dial_select_option)->entry), color_name[WHITE] );
    }

    gtk_box_pack_end(GTK_BOX(hbox), dial_select_option, FALSE, FALSE, 0);
    gtk_box_pack_end(GTK_BOX(hbox), label, FALSE, FALSE, 0);

    gtk_container_add(GTK_CONTAINER(vbox2), hbox);

	/* Seconds Color */

    hbox = gtk_hbox_new(FALSE, 0);

    s_label = gtk_label_new("Seconds Color " );

    for ( i = 0; i < MAX_DARK_BG_COLORS; i++ )
    {
      s_items = g_list_append (s_items, color_name[i] );
    }

    sec_select_option = gtk_combo_new();
    gtk_combo_set_popdown_strings (GTK_COMBO (sec_select_option), s_items);
    gtk_combo_set_value_in_list( GTK_COMBO(sec_select_option), TRUE, FALSE );
    if ( enable_dark_bg ) {
       gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(sec_select_option)->entry), color_name[s_color] );
    } else {
       gtk_entry_set_text(GTK_ENTRY(GTK_COMBO(sec_select_option)->entry), color_name[RED] );
    }

    gtk_box_pack_end(GTK_BOX(hbox), sec_select_option, FALSE, FALSE, 0);
    gtk_box_pack_end(GTK_BOX(hbox), s_label, FALSE, FALSE, 0);

    gtk_container_add(GTK_CONTAINER(vbox2), hbox);
    gtk_container_add(GTK_CONTAINER(vbox), vbox2);

    label = gtk_label_new("Options");
    gtk_container_add(GTK_CONTAINER(frame), vbox);
    gtk_notebook_append_page(GTK_NOTEBOOK(tabs), frame, label);

        /* help */
	vbox1 = gkrellm_gtk_framed_notebook_page(tabs, _("Help"));
	text = gkrellm_gtk_scrolled_text_view(vbox1, NULL,
				GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);
	for (i = 0; i < sizeof(help_text)/sizeof(gchar *); ++i)
		gkrellm_gtk_text_view_append(text, _(help_text[i]));

        /* about */
    about_text = g_strdup_printf(
        "GKrellAclock %s\n" \
        "GKrellM Aclock Plugin\n" \
        "\n" \
        "Copyright (C) 2006 M.R.Muthu Kumar\n" \
        "m_muthukumar@users.sourceforge.net\n" \
        "\n" \
        "Released under the GNU Public License\n" \
	"GkrellAclock comes with ABSOLUTELY NO WARRANTY\n" \
        , GKRELLACLOCK_VER
    );
    about_label = gtk_label_new(about_text);
    g_free(about_text);
    label = gtk_label_new("About");
    gtk_notebook_append_page(GTK_NOTEBOOK(tabs), about_label, label);
}


/* The monitor structure tells GKrellM how to call the plugin routines.
*/
static GkrellmMonitor	plugin_mon	=
	{
	CONFIG_NAME,        	/* Name, for config tab.    */
	0,			/* Id,  0 if a plugin       */
	create_plugin,		/* The create function      */
	update_plugin,			/* The update function      */
	create_aclock_tab,		/* The config tab create function   */
	apply_aclock_config,	/* Apply the config function        */ 
	save_aclock_config,		/* Save user config*/
	load_aclock_config,		/* Load user config*/
	PLUGIN_CONFIG_KEYWORD,	/* config keyword*/ 
	NULL,			/* Undefined 2	*/
	NULL,			/* Undefined 1	*/
	NULL,			/* private		*/ 
	MON_CAL,		/* Insert plugin before this monitor*/ 
	NULL,			/* Handle if a plugin, filled in by GKrellM */
	NULL			/* path if a plugin, filled in by GKrellM   */
	};


  /* All GKrellM plugins must have one global routine named init_plugin()
  |  which returns a pointer to a filled in monitor structure.
  */
#if defined(WIN32)
__declspec(dllexport) GkrellmMonitor *
gkrellm_init_plugin(win32_plugin_callbacks* calls)
#else
GkrellmMonitor *
gkrellm_init_plugin()
#endif
	{
      gint i;
#if defined(WIN32)
    callbacks = calls;
#endif

	/* If this call is made, the background and krell images for this plugin
	|  can be custom themed by putting bg_meter.png or krell.png in the
	|  subdirectory STYLE_NAME of the theme directory.  Text colors (and
	|  other things) can also be specified for the plugin with gkrellmrc
	|  lines like:  StyleMeter  STYLE_NAME.textcolor orange black shadow
	|  If no custom themeing has been done, then all above calls using
	|  style_id will be equivalent to style_id = DEFAULT_STYLE_ID.
	*/
	style_id = gkrellm_add_meter_style(&plugin_mon, STYLE_NAME); 

	/* style_id = gkrellm_lookup_meter_style_id(CAL_STYLE_NAME); */


    d_color = WHITE;
	s_color = RED;
	cycle   = 1;
        clock_type = X_CLOCK;
        enable_dark_bg = FALSE;


	chart_w = gkrellm_chart_width();

    rgbbuf = g_new0( guchar, chart_w * CHART_H * 3 );


    for ( i = 0 ; i < MAX_COLORS ; i++ )
	{
      c_red[i]   = r_value[i];
	  c_green[i] = g_value[i];
	  c_blue[i]  = b_value[i];
	}

	mon = &plugin_mon;
	return &plugin_mon;
	}
