FILES_TO_LINT = libp2p tests tests_interop examples setup.py
PB = libp2p/crypto/pb/crypto.proto \
	libp2p/pubsub/pb/rpc.proto \
	libp2p/security/insecure/pb/plaintext.proto \
	libp2p/security/secio/pb/spipe.proto \
	libp2p/identity/identify/pb/identify.proto
PY = $(PB:.proto=_pb2.py)
PYI = $(PB:.proto=_pb2.pyi)

# Set default to `protobufs`, otherwise `format` is called when typing only `make`
all: protobufs

format:
	black $(FILES_TO_LINT)
	isort --recursive $(FILES_TO_LINT)
	docformatter -ir --pre-summary-newline $(FILES_TO_LINT)

lintroll:
	mypy -p libp2p -p examples --config-file mypy.ini
	black --check $(FILES_TO_LINT)
	isort --recursive --check-only $(FILES_TO_LINT)
	docformatter --pre-summary-newline --check --recursive $(FILES_TO_LINT)
	flake8 $(FILES_TO_LINT)

protobufs: $(PY)

%_pb2.py: %.proto
	protoc --python_out=. --mypy_out=. $<

clean-proto:
	rm -f $(PY) $(PYI)

clean:
	find . -name '__pycache__' -exec rm -rf {} +
	rm -fr build/
	rm -fr dist/
	rm -fr *.egg-info

package: clean
	python setup.py sdist bdist_wheel
	python scripts/release/test_package.py
