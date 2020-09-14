const functions = require('firebase-functions');
// Imports the Google Cloud client library
const {Storage} = require('@google-cloud/storage');

const bucketName = 'software-reliability.appspot.com';

// Creates a client
const storage = new Storage({
  projectId: "software-reliability",
  keyFilename:"software-reliability-b5225e25c67e.json"
});
//const storage = new Storage();

// Create and Deploy Your First Cloud Functions
// https://firebase.google.com/docs/functions/write-firebase-functions
// curl -H 'Content-Type: application/json' https://us-central1-software-reliability.cloudfunctions.net/helloWorld

exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.teste = functions.https.onRequest((request, response) => {

  if ( typeof request.query.id !== 'undefined' && request.query.id ) {

    const filename = 'collected-'+request.query.id+'.zip';

    const bucket = storage.bucket(bucketName);
    const file = bucket.file(filename);

    const options = {
      //version: 'v2', // defaults to 'v2' if missing.
      action: 'write',
      contentType: 'application/zip',
      expires: Date.now() + 1000 * 60 * 10, // 10 minutes
    };

    file.getSignedUrl(options)
      .then(function(data) {
        const url = data[0];
        console.log('The signed url: '+ data[0]);
        response.redirect(
        //response.send( 
          data[0]
        );
    });

  } else {
    response.status(403).send('id is required');
  }

});

// https://github.com/googleapis/nodejs-storage/blob/master/samples/generateV4SignedPolicy.js
// https://cloud.google.com/storage/docs/xml-api/post-object#node.js

// curl -v --upload-file my-file.txt -H "Authorization: Bearer `gcloud auth print-access-token`" 'https://storage.googleapis.com/my-bucket/my-file.txt'

// uploader@software-reliability.iam.gserviceaccount.com
// https://stackoverflow.com/questions/25158266/how-to-allow-anonymous-uploads-to-cloud-storage
// https://cloud.google.com/storage/docs/access-control/signing-urls-manually


//gsutil signurl -m PUT -d 1d /home/matheusneves/Downloads/software-reliability-b5225e25c67e.json gs://software-reliability.appspot.com/testfile.txt
//curl -X PUT --upload-file file.txt -H 'content-type: text/plain' 'https://storage.googleapis.com/software-reliability.appspot.com/testfile.txt?x-goog-signature=4b915dbb590afd1ffee6549632ce0a17723ebfc98130163697eb1ec22c0b5fa4622a6fdad5193565928ec3ecc4988a328592fffa6f196151b621081c574debd0ba2d3b63445c5caef994d20d6309505ed8a32c71ce3813a4d79fa161c4fc0a76465254f5219ba78ab609a7c6d30046142961f362a0d2b045f76bad187e76b625ba8fa5286dbebe6379c1119fdcae5d60f91578c574630660742a58fd43aaf2e7d21b85deab715fff6d0ca3e12c9203efc21757bfd1b576b530d7715668c2e64698a09dad7183550e60626b7139d731c069e219d8209a613ae69e520db58438d33d879b5bb5b65fcc138086d7cb98bcfcd40edbb046026da485f7d83d09aba752&x-goog-algorithm=GOOG4-RSA-SHA256&x-goog-credential=uploader%40software-reliability.iam.gserviceaccount.com%2F20200912%2Fus%2Fstorage%2Fgoog4_request&x-goog-date=20200912T015158Z&x-goog-expires=86400&x-goog-signedheaders=host'

//curl -L -X PUT --upload-file file.txt -H 'content-type: text/plain' 'https://us-central1-software-reliability.cloudfunctions.net/redirect'
//curl -L -X PUT --upload-file file.txt -H 'content-type: text/plain' 'http://localhost:5001/software-reliability/us-central1/teste'
//curl -L -X PUT --upload-file file.txt -H 'content-type: text/plain' 'https://us-central1-software-reliability.cloudfunctions.net/teste'
