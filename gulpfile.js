'use strict';

var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    nodemon = require('gulp-nodemon'),
    tinylr = require('tiny-lr'),
    LIVE_RELOAD_PORT = 35733,
    clientCoffeeSrc = './client/**/*.coffee',
    serverCoffeeSrc = './server/**/*.coffee';

gulp.task('server-coffee', function() {

  return gulp.src( serverCoffeeSrc )
    .pipe( coffee({sourceMap: true}).on('error', gutil.log) )
    .pipe( gulp.dest('build/server') );
});

gulp.task('client-coffee', function() {

  return gulp.src( clientCoffeeSrc )
    .pipe( coffee({sourceMap: true}).on('error', gutil.log) )
    .pipe( gulp.dest('build/client') );
});

gulp.task('client-build', ['client-coffee']);
gulp.task('server-build', ['server-coffee']);
gulp.task('build', ['client-build', 'server-build']);

gulp.task('default', ['build'], function() {

  var lr = tinylr();
  lr.listen(LIVE_RELOAD_PORT);

  var watcher = gulp.watch(['./client/**/*'], ['client-build']);

  watcher.on('change', function(e) {
    gutil.log('File ' + e.path + ' was ' + e.type + ', building again...');
    lr.changed({ body: { files: [require('path').relative(__dirname, e.path)] } });
  });

  nodemon({
    script: 'build/server/index.js',
    ext: 'coffee',
    watch: ['server']
  })
  .on('change', ['server-build']);
});