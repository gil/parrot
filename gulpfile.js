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
    concat = require('gulp-concat'),
    ngHtml2Js = require('gulp-ng-html2js'),
    imagemin = require('gulp-imagemin'),
    LIVE_RELOAD_PORT = 35733;

var paths = {
  clientIndex : './client/index.html',
  clientCoffeeSrc : './client/**/*.coffee',
  serverCoffeeSrc : './server/**/*.coffee',
  clientTemplatesSrc : './client/templates/**/*.tpl.html',
  clientImages : './client/img/**/*',
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

gulp.task('templates', ['client-coffee'], function() {

  return gulp.src( paths.clientTemplatesSrc )
    .pipe( minifyHtml({ empty: true, conditionals: true, spare: true, quotes: true }) )
    .pipe( ngHtml2Js({ moduleName: 'appTemplates', prefix: 'templates/' }) )
    .pipe( concat('templates.js') )
    .pipe( gulp.dest('build/client') );
});

gulp.task('compress-images', function() {

  return gulp.src( paths.clientImages )
    .pipe( imagemin() )
    .pipe( gulp.dest('build/client/img') );
});

gulp.task('compress-code', ['client-coffee', 'templates'], function() {

  return gulp.src( paths.clientIndex )
    .pipe(usemin({
      css: [ minifyCss(), 'concat', rev() ],
      html: [ minifyHtml({ empty: true, conditionals: true, spare: true, quotes: true }) ],
      js: [ ngmin(), uglify({ outSourceMap: true }), rev() ]
    }))
    .pipe( gulp.dest('build/client') );
});

gulp.task('build', ['server-coffee', 'client-coffee', 'templates', 'compress-images', 'compress-code']);

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