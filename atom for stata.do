//Using Atom for Stata

//Why use Atom?
  //Cutting edge text editor of the 21st century (first released in 2015)!
  //Version control, because Github is included! Keep track of all your changes!
  //Fully customized syntax and grammers! Atom is hackable. You can change all the rules!
  //Cross language coding (script package) - Python, R-script, do-file, all in one file.
  //Terminal support - no need to run terminal seperately
  //It's free!

//Courtesy to Dr. STEPHANIE LACKNER
//https://slackner.com/2018/03/02/stata-in-atom/

//In Terminal:
//apm install stata-exec
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
