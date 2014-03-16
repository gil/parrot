'use strict';

var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    nodemon = require('gulp-nodemon'),
    clientCoffeeSrc = './client/**/*.coffee',
    serverCoffeeSrc = './server/**/*.coffee',
    templatesSrc = './client/views/*.html',
    styleSrc = './client/styles/*.css';

gulp.task('server-coffee', function() {

  gulp.src( serverCoffeeSrc )
    .pipe( coffee({sourceMap: true}).on('error', gutil.log) )
    .pipe( gulp.dest('build/server') );
});

gulp.task('client-coffee', function() {

  gulp.src( clientCoffeeSrc )
    .pipe( coffee({sourceMap: true}).on('error', gutil.log) )
    .pipe( gulp.dest('build/client') );
});

gulp.task('html', function() {

  gulp.src( '*.html' )
    .pipe( gulp.dest('build/client') );

  gulp.src( templatesSrc )
    .pipe( gulp.dest('build/client/views') );

  // TODO: Remove later, change to other plugin
  gulp.src( 'bower_components/**/*' )
    .pipe( gulp.dest('build/client/bower_components') );
});

gulp.task('img', function() {

  gulp.src( 'client/img/*' )
    .pipe( gulp.dest('build/client/img') );

});

gulp.task('style', function() {

  gulp.src( styleSrc )
    .pipe( gulp.dest('build/client/styles') );
});

gulp.task('client-build', ['client-coffee', 'html', 'style', 'img']);
gulp.task('build', ['client-build', 'server-coffee']);

gulp.task('default', ['build'], function() {

  var watcher = gulp.watch([clientCoffeeSrc, templatesSrc, styleSrc], ['client-build']);

  watcher.on('change', function(e) {
    gutil.log('File ' + e.path + ' was ' + e.type + ', building again...');
  });

  nodemon({
    script: 'build/server/index.js',
    ext: 'coffee',
    watch: ['server']
  })
  .on('change', ['server-coffee']);
});

