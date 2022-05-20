# FAQ

1. Meaning of the word Massa

## First 

Massa: Mass is a direct measure of the opposition that a body offers to change in its State of motion.

## Second

**Massa** comes from the Latin massa, which means dough, paste, and comes from the Greek, “barley cake”, which in turn comes from mássein, which means “to knead, join, unite”. Mass, we already know, is not the same as weight, as it concerns the force with which a mass is attracted by gravity. In practice, however, weight has been used as a mass control.

The word weight comes from the Latin pensum, derived from the verb pendere, which means to hang, to be pending. Two used weights standards were used as standard pens for two used weights. If you thought the word pensum has to do with thought, you're right! The act of thinking is precisely that of comparing things, evaluating them as on a scale, whose name, by the way, comes from bi-lanx, which in Latin literally means two plates.

Another Latin name for this instrument is libra. Thus, the word balance comes from the Latin aequilibrium, adjusted from aequi (equal) and librare (to oscillate). To balance means to oscillate like a scale (to pound) to find the equivalent weight. Libra is also at the root of deliberating, which means making a decision after evaluating, thinking.

Finally, in English pound is pound (Unit of measurement of the Imperial System which is equivalent to 0.4536 kg), which in turn came from the Latin pondus, “weight”, from ponderare, “to weigh”. Pondering means evaluating, thinking. As you can see, there is an intimate connection between and thinking. Thinking well, in order to think well, you have to weigh well.

## Finally

"Massa" is a word from the Portuguese language, in fact one of the founders of Eigr is Brazilian, and therefore a native speaker of the Portuguese language. As described in the previous chapters, the etymological root of the word as well as its metrology does not allow an association of the word Massa with the English word Master. For a Portuguese speaker this association is completely impossible to achieve and therefore it must be considered that the name of our Proxy Sidecar is Portuguese and is based on the meaning given to the physics of the word Massa and has no relationship, given that this relationship is impossible to achieve, with the English word Master.

It should be noted that the Eigr community repudiates any form of prejudice of any kind and that this community respects and values human rights.

2. BEAM cold startup time in serverless environments?

The important thing is to emphasize that Serveless cannot be confused with Amazon Lambda. That while Amazon Lambda and Lambda-like Serverless technologies are an implementation of the Serveless concept, this is nowhere near the norm. That serveless is much more about abstracting the underlying infrastructure from developers than about "cold starts fast". And because of the other features of BEAM, we can support a Serveless model that guarantees that your data will be distributed and partitioned in a cluster and that this data can be placed together with the instances of the user functions both in scale-up events and in horizontal scale events to Zero.
All this without the developer user having to worry about how this data is being persisted, stored, manipulated, all he cares about is the business domain and what business problems he wants to solve.

3. How do we handle the state of entities when they are scaled to Zero?

Thanks to Erlang's Genservers we can safely Enable and Disable user functions by adding persistence hooks during shutdown events. Including migrating the processes responsible for user data across the cluster as needed.

4. Why Kubernetes?

While BEAM has fantastic fault-tolerance and distribution features these features are found at the user software layer and not at the infrastructure layer. Kubernetes in turn acts at the infrastructure layer and together with BEAM allows us to guarantee a much higher quality of service while allowing us to use a mechanism that is in fact the industry standard for both discovery of nodes in a network and execution industry standard, which is container orchestration. Remembering that we support multiple languages and that the standard is about running containers and in this case Kubernetes is in fact the standard to be followed.

The two together BEAM and Kubernetes are much stronger than either one in isolation.
