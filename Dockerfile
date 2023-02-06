FROM mcr.microsoft.com/devcontainers/base:ubuntu
LABEL Piotr ZAWADZKI "pzawadzki@polsl.pl"

# # whether to install documentation and/or source files
# # this has to be yes or no
# ARG DOCFILES=no
# ARG SRCFILES=no
# ARG SCHEME=full

# # the mirror from which we will download TeX Live
# ARG TLMIRRORURL=https://sunsite.icm.edu.pl/pub/CTAN/systems/texlive/

# # whether to create font and ConTeXt caches
# ARG GENERATE_CACHES=yes

# ENV REBUILD_VER 2023.02.05v1

# USER root

# RUN apt-get update && \
#   export DEBIAN_FRONTEND=noninteractive && \
#   # basic utilities for TeX Live installation
#   apt-get install -qy --no-install-recommends curl git unzip \
#   # miscellaneous dependencies for TeX Live tools
#   make fontconfig perl default-jre libgetopt-long-descriptive-perl \
#   libdigest-perl-md5-perl libncurses5 libncurses6 \
#   # for latexindent (see #13)
#   libunicode-linebreak-perl libfile-homedir-perl libyaml-tiny-perl \
#   # for eps conversion (see #14)
#   ghostscript \
#   # for metafont (see #24)
#   libsm6 \
#   # for syntax highlighting
#   python3 python3-pygments \
#   # for gnuplot backend of pgfplots (see !13)
#   gnuplot-nox && \
#   rm -rf /var/lib/apt/lists/* && \
#   rm -rf /var/cache/apt/ 

# WORKDIR /tmp

# RUN echo "Fetching installation from mirror $TLMIRRORURL" && \
#   # or curl instead of wget
#   wget $TLMIRRORURL/tlnet/install-tl-unx.tar.gz  && \
#   zcat install-tl-unx.tar.gz | tar xf - && \
#   cd install-tl-* && \
#   # create installation profile for full scheme installation with
#   # the selected options
#   echo "Building with documentation: $DOCFILES" && \
#   echo "Building with sources: $SRCFILES" && \
#   echo "Building with scheme: $SCHEME" && \
#   # choose complete installation
#   echo "selected_scheme scheme-$SCHEME" > install.profile && \
#   # … but disable documentation and source files when asked to stay slim
#   if [ "$DOCFILES" = "no" ]; then echo "tlpdbopt_install_docfiles 0" >> install.profile && \
#     echo "BUILD: Disabling documentation files"; fi && \
#   if [ "$SRCFILES" = "no" ]; then echo "tlpdbopt_install_srcfiles 0" >> install.profile && \
#     echo "BUILD: Disabling source files"; fi && \
#   echo "tlpdbopt_autobackup 0" >> install.profile && \
#   # furthermore we want our symlinks in the system binary folder to avoid
#   # fiddling around with the PATH
#   echo "tlpdbopt_sys_bin /usr/bin" >> install.profile && \
#   # actually install TeX Live
#   ./install-tl -profile install.profile && \
#   cd .. && \
#   rm -rf texlive

# WORKDIR /

# RUN echo "Set PATH to $PATH" && \
#   $(find /usr/local/texlive -name tlmgr) path add && \
#   # pregenerate caches as per #3; overhead is < 5 MB which does not really
#   # matter for images in the sizes of GBs; some TL schemes might not have
#   # all the tools, therefore failure is allowed
#   if [ "$GENERATE_CACHES" = "yes" ]; then \
#     echo "Generating caches" && \
#     (luaotfload-tool -u || true) && \
#     (mtxrun --generate || true) && \
#     # also generate fontconfig cache as per #18 which is approx. 20 MB but
#     # benefits XeLaTeX user to load fonts from the TL tree by font name
#     (cp "$(find /usr/local/texlive -name texlive-fontconfig.conf)" /etc/fonts/conf.d/09-texlive-fonts.conf || true) && \
#     fc-cache -fsv; \
#   else \
#     echo "Not generating caches"; \
#   fi

# RUN \
#   # test the installation; we only test the full installation because
#   # in that, all tools are present and have to work
#   if [ "$SCHEME" = "full" ]; then \
#     latex --version && printf '\n' && \
#     bibtex --version && printf '\n' && \
#     biber --version && printf '\n' && \
#     xindy --version && printf '\n' && \
#     arara --version && printf '\n' && \
#     if [ "$DOCFILES" = "yes" ]; then texdoc -l geometry; fi && \
#     if [ "$SRCFILES" = "yes" ]; then kpsewhich amsmath.dtx; fi; \
#   fi && \
#   pygmentize -V && printf '\n'
#   # python --version && printf '\n' && \

WORKDIR /home/vscode

USER vscode
