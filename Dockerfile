# vim:fileencoding=utf-8:foldmethod=marker
FROM docker.io/ubiqube/msa2-linuxdev:latest AS builder
USER 1000
WORKDIR /home/ncuser

ENV BIN_DIR=/opt/fmc_repository/Process/PythonReference/bin
RUN install_default_dirs.sh

# Install fortinet-ms {{{
COPY --chown=1000:1000 . /opt/fmc_repository/fortinet-ms
RUN install_repo_deps.sh /opt/fmc_repository/fortinet-ms/

# Cleanup repository {{{
RUN rm -rf /opt/fmc_repository/fortinet-ms/{.git,docker,Dockerfile}
# }}}
# Build tarball {{{
RUN echo "⏳ Creating fmc-repository.tar.xz" && \
    chmod a+w -R /opt/fmc_repository/ && \
    tar cf fmc-repository.tar.xz --exclude-vcs /opt/fmc_repository/ -I 'xz -T0' --checkpoint=1000 --checkpoint-action=echo='%{%Y-%m-%d %H:%M:%S}t ⏳ \033[1;37m(%d sec)\033[0m: \033[1;32m#%u\033[0m, \033[0;33m%{}T\033[0m'
# }}}

FROM docker.io/ubiqube/ubi-almalinux9:latest
# Copy all resources to the final image {{{
RUN mkdir -p /opt/fmc_repository && chown -R 1000:1000 /opt/fmc_repository
USER 1000
COPY --from=builder /home/ncuser/*.xz /home/ncuser/
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
# }}}
