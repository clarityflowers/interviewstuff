const request = require("request");

const getBody = (response, body) => {
  if (response.body) return response.body;
  throw new Error("response had no body");
};

const get = path =>
  new Promise((resolve, reject) =>
    request("http://api.conceptnet.io" + path, (error, response, body) => {
      if (error) {
        reject(error);
      } else {
        resolve(response, body);
      }
    })
  )
    .then(getBody)
    .then(JSON.parse);

const blah = (prevEdges, path) => {
  console.log(path);
  return get(path).then(({ error, edges, view }) => {
    if (error) {
      throw new Error(error.details);
    }
    if (view.nextPage) {
      return blah(prevEdges.concat(edges), view.nextPage);
    } else {
      return prevEdges.concat(edges);
    }
  });
};

const getAll = path => blah([], `/c/en/${path}?limit=100`);

console.log("Fetching");
return getAll(process.argv[2])
  .then(data => {
    const grouped = [];
    data
      .filter(
        edge => edge.start.language === "en" && edge.end.language === "en"
      )
      .sort((a, b) => a.rel.label.localeCompare(b.rel.label))
      .forEach(edge => {
        if (!grouped.length) {
          grouped.push([edge]);
        } else {
          const thisGroup = grouped[grouped.length - 1];
          const lastEdge = thisGroup[thisGroup.length - 1];
          if (lastEdge.rel.label !== edge.rel.label) {
            grouped.push([edge]);
          } else {
            thisGroup.push(edge);
          }
        }
      });

    for (const group of grouped) {
      console.log("");
      console.log("\033[32m" + group[0].rel.label + "\033[0m");
      console.log("-----------------");
      for (const edge of group) {
        console.log(`${edge.start.label} -> ${edge.end.label}`);
      }
    }
  })
  .catch(error => {
    console.error(error);
  });
