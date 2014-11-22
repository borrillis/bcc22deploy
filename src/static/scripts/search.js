function search(queryTerm) {
    if ( !isNullOrWhitespace(queryTerm) ) {
        serviceURI = serviceURI.replace('{QUERYTERM}', queryTerm);
        $('#page header h1').text('Search results for "' + queryTerm + '"');
        $.ajax({
            dataType: "json",
            type: 'GET',
            url: serviceURI,
            headers: {
                "Authorization": "Basic MCtMZzA4b011bDM2UHdtdU1KcjlabDUvWWFNeGxmQUdmbEJwQnhWZlBFVT06MCtMZzA4b011bDM2UHdtdU1KcjlabDUvWWFNeGxmQUdmbEJwQnhWZlBFVT0="
            }
        }).done(function (data) {
            var results = data.d.results;
            var resultList = document.getElementById('resultList');

            for (i = 0; i < results.length; i++) {
                var item = results[i];
                var listItem = document.createElement('li');

                var article = document.createElement('article');
                article.setAttribute('class', 'content-item blog-post');

                var header = document.createElement('header');

                var titleHeader = document.createElement('h1');

                var title = document.createElement('a');
                title.setAttribute('href', item.Url);
                var titleText = document.createTextNode(item.Title);
                title.appendChild(titleText);
                titleHeader.appendChild(title);

                header.appendChild(titleHeader);

                var description = document.createElement('div');
                description.setAttribute('class', 'post-content');
                var descText = document.createTextNode(item.Description);
                description.appendChild(descText);

                var url = document.createElement('div');
                url.setAttribute('class', 'metadata');
                var urlText = document.createTextNode(item.DisplayUrl);
                url.appendChild(urlText);

                article.appendChild(header);
                article.appendChild(url);
                article.appendChild(description);


                listItem.appendChild(article);

                resultList.appendChild(listItem);
                $('#loading').remove();
            }
        }).fail(function (jqXHR, textStatus, errorThrown) {
            alert(textStatus);
            alert(errorThrown);
        });
    }
}

var serviceURI = "https://api.datamarket.azure.com/Bing/SearchWeb/v1/Web?$format=json&Query=%27site%3Amichaelcummings.net%20{QUERYTERM}%27";

$(function () {
    search(urlParams['q']);
});
