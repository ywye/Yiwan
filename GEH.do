*Gender Perspective on Education Effect on Health
*Project goals
  /*
  conduct fixed effect analysis for the
  "Gender Difference in Benefits from Education
  to Health Across Cohorts in China:
  Resource Substitution and Rising Importance" paper.
  */

  pwd

  cd "/Users/wanleaf/Documents/Projects/QP/Data"
  use "ehg.3.dta"

codebook, compact

  *Health outcomes
    tab1 health, m nolab /*only five catergories, consider ologit*/
      hist health
        kdensity health /*shows multinomial patterns*/

  *Education
    tab1 eduy, m nolab
      hist eduy
        kdensity eduy /*should be treated as a catergorical variable*/

  reg health i.eduy

  *Gender
    tab1 male, m nolab
