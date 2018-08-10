.PHONY: authors cli run-tests clean

authors:
	git log --format='%aN <%aE>' | sort -u --ignore-case | grep -v 'users.noreply.github.com' > AUTHORS.txt && \
	git add AUTHORS.txt && \
	git commit AUTHORS.txt -m 'Updating AUTHORS'

cli:
	cp LICENSE bin/docs/LICENSE && \
	cp DISCLAIMER bin/docs/DISCLAIMER

run-tests:
	make -C tests/ run-tests

clean:
	make -C tests/ clean
