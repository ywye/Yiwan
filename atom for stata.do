//Quantea Miniworkshop: Atom for Social Scienctist (15 mins)

//Objective:
#1. what is Atom, why you may need it.
#2. how to install Atom & set up github on Mac OS.
#3. how to set up Atom for writing Stata syntax.
#4. how to do version control, a.k.a. github in atom.
#5. [Advanced], learn how to edited snippets (hacking).

//Requirements: Mac OS, Stata or R installed

//Why use Atom?
  //Vs. git: git is too basic, not user friendly.
  //Vs. github: can't do coding simultaneously
  //Vs. Stata's do-file editor: only works for stata code, no version control, syntax rules are fixed.
  //Vs. text-wrangler/sublime do have version control (online or local), syntax rules are mostly fixed.
  //Atom is develped by company that made github.

  //Cutting edge text editor of the 21st century (first released in 2015).
  //Fully supportive version control, because Github is included! Keep track of all your changes.
  //Fully customizable syntax and grammers! Atom is hackable. You can change all the rules.
  //Cross language coding (script package) - Python, R-script, do-file, all in one file.
  //Terminal support - no need to run terminal seperately
  //It's free!



//Courtesy to Dr. STEPHANIE LACKNER
//https://slackner.com/2018/03/02/stata-in-atom/

//In Terminal:
//apm install stata-exec, or in atom settt

//amp install language-stata

//cmd + shift + p, search "stata exec"
//to execute the code, highlight and type cmd + return

`cmd + shift + p' : `settings view: installed packages'
//search for language-stata, and click on viewcode

//go to the snippet folder and add the following lines before the

#customized stata command snippets starts here
  'two-way table':
        'prefix': 'tab2'
        'body': 'tab $1 $2, all col row m'
#end of customized stata command snippets

//As it turns out, you can actually run unix shell code in Stata.




//LaTex
//https://slackner.com/2018/03/08/animations-in-latex-with-the-animate-package/

//Lyx for Mac
//Need to install MacTeX first
//https://www.lyx.org/Download
