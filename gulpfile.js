'use strict';

var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    nodemon = require('gulp-nodemon'),
    tinylr = require('tiny-lr'),
    ngmin = require('gulp-ngmin'),
    uglify = require('gulp-uglify'),
    LIVE_RELOAD_PORT = 35733;

var paths = {
  clientCoffeeSrc : './client/**/*.coffee',
  serverCoffeeSrc : './server/**/*.coffee',
  clientBuildScripts : './build/client/**/*.js',
  clientBuildFiles : './build/client/**/*',
  serverFile : 'build/server/index.js'
};

gulp.task('server-coffee', function() {

  return gulp.src( paths.serverCoffeeSrc )
    .pipe( coffee({ sourceMap: true }).on('error', gutil.log) )
    .pipe( gulp.dest('build/server') );
});

gulp.task('client-coffee', function() {

  return gulp.src( paths.clientCoffeeSrc )
    .pipe( coffee({ sourceMap: true }).on('error', gutil.log) )
    .pipe( gulp.dest('build/client') );
});

gulp.task('compress-js', ['client-coffee'], function() {

  return gulp.src( paths.clientBuildScripts )
    .pipe( ngmin() )
    .pipe( uglify({ outSourceMap: true }) )
    .pipe( gulp.dest('build/client') );
});

gulp.task('build', ['client-coffee', 'server-coffee', 'compress-js']);

gulp.task('default', ['client-coffee', 'server-coffee'], function() {

  var lr = tinylr();
  lr.listen(LIVE_RELOAD_PORT);

  var watcher = gulp.watch([paths.clientBuildFiles], ['client-coffee']);

  watcher.on('change', function(e) {
    gutil.log('File ' + e.path + ' was ' + e.type + ', building again...');
    lr.changed({ body: { files: [require('path').relative(__dirname, e.path)] } });
  });

  nodemon({
    script: paths.serverFile,
    ext: 'coffee',
    watch: ['server']
  })
  .on('change', ['server-coffee']);
});