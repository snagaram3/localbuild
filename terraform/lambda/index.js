exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));

    const response = {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from LocalStack Lambda!',
            timestamp: new Date().toISOString(),
            event: event
        }),
    };

    return response;
};
