FROM amazon/aws-lambda-python:3.9-x86_64
COPY requirements.txt .
RUN pip3 install -r requirements.txt
COPY index.py ./

CMD ["index.lambda_handler"]
