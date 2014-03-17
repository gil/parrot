'use strict';

var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    nodemon = require('gulp-nodemon'),
    tinylr = require('tiny-lr'),
    usemin = require('gulp-usemin'),
    ngmin = require('gulp-ngmin'),
    uglify = require('gulp-uglify'),
    minifyHtml = require('gulp-minify-html'),
    minifyCss = require('gulp-minify-css'),
    rev = require('gulp-rev'),
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

gulp.task('compress', ['client-coffee'], function() {

  gulp.src( './client/*.html' )
    .pipe(usemin({
      css: [minifyCss(), 'concat', rev()],
      html: [minifyHtml({empty: true})],
      js: [ngmin(), uglify({ outSourceMap: true }), rev()]
    }))
    .pipe(gulp.dest('build/client'));
});

gulp.task('build', ['client-coffee', 'server-coffee', 'compress']);

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