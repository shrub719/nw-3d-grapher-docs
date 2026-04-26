## 4.2 Testing evidence

Continuous integration testing was done throughout the life cycle of the project,
which was necessary to ensure that the program compiled to its intended bare metal
target. It allowed me to verify that the program accessed and worked with the EADK
seemlessly at each stage of development.

Unit tests (found in `tests.rs`) were developed for several objectives where it seemed most appropriate.
Objectives which focused on fixed functional targets with no side effects were
more efficient to do via unit tests, but more complex user input-related interactions
were left to the test video.

![Unit test results](assets/unit-tests.png)

[Test video](https://youtube.com/playlist?list=PLruYK8pH0OlxH-p7s-8bkWWg6U7TUMrPB&si=FWgMh-WrX74SVlI_)

