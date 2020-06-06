using CommonMark

template(body) = raw"""
\documentclass[12pt,a4paper]{article}

\usepackage[a4paper,text={16.5cm,25.2cm},centering]{geometry}
\usepackage{lmodern}
\usepackage{amssymb,amsmath}
\usepackage{graphicx}
% \usepackage{svg}
% \svgsetup{inkscapelatex=false}
\usepackage{microtype}
\usepackage{hyperref}
\setlength{\parindent}{0pt}
\setlength{\parskip}{1.2ex}

\usepackage{placeins}

\let\Oldsection\section
\renewcommand{\section}{\FloatBarrier\Oldsection}

\let\Oldsubsection\subsection
\renewcommand{\subsection}{\FloatBarrier\Oldsubsection}

\usepackage{float}
\floatplacement{figure}{h!}

\usepackage[defaultlines=3,all]{nowidow}

\title{PeaceVote}

\author{Janis Erdmanis}

\usepackage[T1]{fontenc}
\usepackage{textcomp}
\usepackage{upquote}
%\usepackage{listings}

\usepackage{jlcode}

\renewcommand{\texttt}[1]{\jlinl{#1}}

\let\verbatim\trash
\lstnewenvironment{verbatim}
{}{}

\let\oldincludegraphics\includegraphics
\renewcommand{\includegraphics}[1]{\oldincludegraphics[width=0.5\textwidth]{#1}}


\begin{document}

\maketitle

% \abstract{PeaceVote abstract}

""" *
body *
raw"""

\include{references}

\end{document}

%%% Local Variables:
%%% mode: latex
%%% TeX-master: t
%%% LaTeX-command:"latex --synctex=1 --shell-escape"
%%% End:
"""

mtext = join(readlines("peacevote.md"),"\n")

markdown = Parser()
enable!(markdown, FootnoteRule())
ast = markdown(mtext)

body = latex(ast)
text = template(body)

open("peacevote.tex", "w") do file
    println(file, text)
end

