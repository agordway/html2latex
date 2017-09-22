%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int list_type;
%}

%option       noyywrap nounput yylineno
%x            COMMENT PARA PRE OL UL LI

%%

"<h1>"[^<]*"</h1>" {
	/**************************************************************************
	 * Matched an HTML H1 header so print it out as a LateX section title.
	 * The beginning and ending tags need to be stripped off before the
	 * title can be formatted in LateX.
	 *************************************************************************/
	yytext[yyleng-5] = 0;
	printf( "\\section{%s}", yytext+4 );
}

"<h2>"[^<]*"</h2>" {
	/**************************************************************************
	 * Matched an HTML H2 header so print it out as a LateX section title.
	 * The beginning and ending tags need to be stripped off before the
	 * title can be formatted in LateX.
	 *************************************************************************/
	yytext[yyleng-5] = 0;
	printf("\\subsection{%s}", yytext+4);
}

"<h3>"[^<]*"</h3>" {
	/**************************************************************************
	 * Matched an HTML H3 header so print it out as a LateX section title.
	 * The beginning and ending tags need to be stripped off before the
	 * title can be formatted in LateX.
	 *************************************************************************/
	yytext[yyleng-5] = 0;
	printf("\\subsubsection{%s}", yytext+4);
}

"<!--" {
	/**************************************************************************
     * Matched an HTML comment so print it out as a LateX comment. The
     * beginning and ending tags are stripped off before the LateX comment
     * is emitted.
     *************************************************************************/
	printf("%% ");
	BEGIN COMMENT;
}

[ \t\n\r]+ {
	/**************************************************************************
	 * Matched some whitespace that is not inside of an HTML tag. We
	 * just ignore the whitespace.
	 *************************************************************************/
}

. {
	/**************************************************************************
	 * Matched something that we did not expect to see. Issue an error and
	 * exit the program with a failure code.
	 *************************************************************************/
	fprintf(stderr, "Unexpected input at line %d: '%s'\n", yylineno, yytext);
	exit(1);
}

<COMMENT>"-->" {
	/**************************************************************************
	 * Matched an HTML end comment while parsing an HTML comment. Print out
	 * a new line and resume normal parsing.
	 *************************************************************************/
	printf("\n");
	BEGIN 0;
}

<COMMENT>[\n](\r)? {
	/**************************************************************************
	 * Matched a newline while parsing an HTML comment. Print out a new
	 * line making sure to mark the next line as a comment as well.
	 *************************************************************************/
	printf("\n%% ");
}

<COMMENT>[ \t] {
	/**************************************************************************
     * Matched some white space while parsing an HTML comment. Print out
     * the white space as is.
     *************************************************************************/
	printf("%s", yytext);
}

<COMMENT>. {
	/**************************************************************************
	 * Matched any other text while parsing an HTML comment. Print out
	 * the text as is.
	 *************************************************************************/
	printf("%s", yytext);
}

"<pre>" {
	/*******************************************************************
	* Matched the HTML PRE tag
	*******************************************************************/

	printf("\\begin{verbatim}");
	BEGIN PRE;
}

<PRE>"[^<]*" {
	/*******************************************************************
	* Matched any other text while parsing a HTML PRE tag
	*******************************************************************/

	printf("%s", yytext);
}

<PRE>"</pre>" {
	/*******************************************************************
	* Matched the HTML PRE end tag. Prints new line after
	*******************************************************************/

	printf("\\end{verbatim}\n");
	BEGIN 0;
}

"<p>"  {
	/*******************************************************************
	* Matched the HTML Paragraph tag
	*******************************************************************/

	BEGIN PARA;
}

<PARA>. {
	/*******************************************************************
	* Matched any other text while pasing a HTML P tag
	*******************************************************************/

	printf("%s", yytext);
}

<PARA>"</p>" {
	/*******************************************************************
	* Matched the HTML Paragraph end tag. Prints 2 new lines after
	*******************************************************************/

	printf("\n\n");
	BEGIN 0;
}

<PARA>[^<]* {
	/*******************************************************************
	* Matched any other text while parsing a HTML P tag
	*******************************************************************/

	printf("%s", yytext);
}

"<ol>" {
	/*******************************************************************
	* Matched the HTML OL tag. Begins enumerate
	*******************************************************************/

	printf("\\begin{enumerate}");
	BEGIN LI;
}

<LI>"</ol>" {
	/*******************************************************************
	* Matched the HTML PRE end tag. Adds newline
	*******************************************************************/

	printf("\\end{enumerate}\n");
	BEGIN 0;
}

"<ul>" {
	/*******************************************************************
	* Matched the HTML UL tag. Begin itemize
	*******************************************************************/

	printf("\\begin{itemize}");
	BEGIN LI;
}

<LI>"</ul>" {
	/*******************************************************************
	* Matched the HTML UL end tag. Adds newline
	*******************************************************************/

	printf("\\end{itemize}\n");
	BEGIN 0;
}

<LI>"<li>" {
	/*******************************************************************
	* Matched the HTML LI tag. 
	*******************************************************************/

	printf("\\item %s", yytext+4);
	BEGIN PARA;
}

<PARA>"</li>" {
	/*******************************************************************
	* Matched the HTML LI end tag. Adds newline
	*******************************************************************/

	printf("\n");
	BEGIN LI;
}

<PARA>"<small>"[^<]*"</small>" {
	/*******************************************************************
	* Matched the HTML SMALL tag.
	*******************************************************************/

	yytext[yyleng-8] = 0;
	printf("{\\scriptsize %s}", yytext+7);
}

<PARA>"<big>"[^<]*"</big>" {
	/*******************************************************************
	* Matched the HTML BIG tag.
	*******************************************************************/

	yytext[yyleng-6] = 0;
	printf("{\\Large %s}", yytext+5);
}

<PARA>"<b>"[^<]*"</b>" {
	/*******************************************************************
	* Matched the HTML B tag
	*******************************************************************/

	yytext[yyleng-4] = 0;
	printf("\\textbf{%s}", yytext+3);
}

<PARA>"<i>"[^<]*"</i>" {
	/*******************************************************************
	* Matched the HTML I tag
	*******************************************************************/

	yytext[yyleng-4] = 0;
	printf("\\textit{%s}", yytext+3);
}

<PARA>"<strong>"[^<]*"</strong>" {
	/*******************************************************************
	* Matched the HTML STRONG tag
	*******************************************************************/

	yytext[yyleng-9] = 0;
	printf("\\textmd{%s}", yytext+8);
}

<PARA>"<em>"[^<]*"</em>" {
	/*******************************************************************
	* Matched the HTML EM tag
	*******************************************************************/

	yytext[yyleng-5] = 0;
	printf("\\emph{%s}", yytext+4);
}

<PARA>"<sup>"[^<]*"</sup>" {
	/*******************************************************************
	* Matched the HTML SUP tag
	*******************************************************************/

	yytext[yyleng-6] = 0;
	printf("\\textsuperscript{%s}", yytext+5);
}

<PARA>"<sub>"[^<]*"</sub>" {
	/*******************************************************************
	* Matched the HTML SUB tag
	*******************************************************************/

	yytext[yyleng-6] = 0;
	printf("\\textsubscript{%s}", yytext+5);
}

%%

/**************************************************************************
* The main function for the HTML to LateX converter. Here we do three
* things:
*  1. Print out the LateX document header.
*  2. Invoke the lexer to print out the LateX document
*  3. Print out the LateX footer.
*************************************************************************/
int main( int argc, const char *argv[] ) {
    printf( "\\documentclass[12pt]{article}\n" );
    printf( "\\usepackage{fixltx2e}\n" );
    printf( "\n" );
    printf( "\\setlength{\\parindent}{0.0in}\n" );
    printf( "\\setlength{\\parskip}{0.125in}\n" );
    printf( "\n\n" );
    printf( "\\begin{document}\n" );
    yylex();
    printf( "\\end{document}\n" );
    return 0;
}
