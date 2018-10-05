Quick instructions.

1. Build the container:

    docker build -t conus_container .

2. Run the container:

    docker run -ti -p 5000:5000 conus_container deepaas-run --listen-ip 0.0.0.0
