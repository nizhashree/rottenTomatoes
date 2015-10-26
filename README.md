# Project 1 - BoxOffice

BoxOffice is a movies app displaying box office and top rental DVDs using the [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON).

Time spent: 6 hours spent in total

## User Stories

The following **required** functionality is completed:

- [x] User can view a list of movies. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API. 
- [x] User sees error message when there is a network error. 
- [x] User can pull to refresh the movie list. Refreshing fades the existing list of movies. So, if an error occurs, displays the error message and fades in the list which was already rendered.

The following **optional** features are implemented:

- [ ] Add a tab bar for Box Office and DVD.
- [ ] Implement segmented control to switch between list view and grid view.
- [x] Add a search bar.
- [x] All images fade in. The images from network alone has the fade in animation. The images from cache are loaded as such
- [x] For the large poster, load the low-res image first, switch to high-res when complete.
- [ ] Customize the highlight and selection effect of the cell.
- [x] Customize the navigation bar.

The following **additional** features are implemented:

- [x] Scroll up to the full page view of the synopsis on the movie details page when scroll up movement gesture is initiated.
- [x] The lower sectional view on the details page is rendered when the scroll down movement is initiated
- [x] Even the list view images has loading the low-res image first, switch to high-res when complete 
- [x] Added loading symbol for loading images on the list view too
- [x] Added bounce effect on the Movie details page synopsis full page view.
 

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/jjF4q4V.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

I faced challenge in bringing up the animation in the details page. I tried various ways: Using Scroll event handler, Gesture event handler. At last settled with Gesture event handlers. I am not sure if it is the right way to do so. There might be other cleaner ways to do so as well.

I faced some more challenges on customizing the tableView. 
- There were separator inlets which was making the view look bad. 
- There were separator lines coming for the empty cells
- UIsearch bar (X) image on the search bar doesnot trigger the cancel event. I had to put an explicit cancel button. 

## License

    Copyright [yyyy] [name of copyright owner]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.