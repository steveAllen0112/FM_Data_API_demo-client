gulp		= require 'gulp'
pug			= require 'gulp-pug'
prettify	= require 'gulp-prettify'
coffee		= require 'gulp-coffee'
scss		= require 'gulp-sass'
sourcemaps	= require 'gulp-sourcemaps'
cache		= require 'gulp-cached'
#concat		= require 'gulp-concat'

gulp.task 'compile-coffee', ->
	gulp.src 'coffees/**/*.coffee', base: './src/coffees/'
		.pipe cache 'coffees'
		.pipe sourcemaps.init()
		.pipe coffee bare: true
		.pipe sourcemaps.write './build/maps'
		.pipe gulp.dest './build/js/'
	
gulp.task 'compile-pug', ->
	gulp.src 'pugs/**/*.pug', base: './src/pugs/'
		.pipe cache 'pug'
		.pipe sourcemaps.init()
		.pipe pug pretty: '	'
		.pipe sourcemaps.write './build/maps'
		.pipe gulp.dest './build/'

gulp.task 'compile-sass', ->
	gulp.src('sass/**/*.scss', base: './src/sass/')
		.pipe scss().on('error', scss.logError)
		.pipe gulp.dest('./build/styles')
		
gulp.task 'watch', ->
	gulp.watch 'src/coffees/**/*.coffee', ['compile-coffee']
	gulp.watch 'src/templates/**/*.pug', ['compile-pug']
	gulp.watch 'src/sass/**/*.scss', ['compile-sass']
	
gulp.task 'default', [ 'compile-pug', 'compile-coffee' , 'compile-sass', 'watch' ]