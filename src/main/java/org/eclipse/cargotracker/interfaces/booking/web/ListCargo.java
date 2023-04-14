package org.eclipse.cargotracker.interfaces.booking.web;

import static java.util.stream.Collectors.toList;

import java.util.List;
import java.util.logging.Logger;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.TransactionAttribute;
import jakarta.ejb.TransactionAttributeType;
import jakarta.enterprise.context.RequestScoped;
import jakarta.inject.Inject;
import jakarta.inject.Named;
import org.eclipse.cargotracker.interfaces.booking.facade.BookingServiceFacade;
import org.eclipse.cargotracker.interfaces.booking.facade.dto.CargoRoute;

/**
 * Handles listing cargo. Operates against a dedicated service facade, and could easily be rewritten
 * as a thick client. Completely separated from the domain layer, unlike the tracking user
 * interface.
 *
 * <p>In order to successfully keep the domain model shielded from user interface considerations,
 * this approach is generally preferred to the one taken in the tracking controller. However, there
 * is never any one perfect solution for all situations, so we've chosen to demonstrate two
 * polarized ways to build user interfaces.
 */
@Named
@RequestScoped
public class ListCargo {

  @Inject private BookingServiceFacade bookingServiceFacade;
  @Inject private Logger logger;

  private List<CargoRoute> notRoutedCargos;
  private List<CargoRoute> routedUnclaimedCargos;
  private List<CargoRoute> claimedCargos;

  @PostConstruct
  @TransactionAttribute(TransactionAttributeType.REQUIRED)
  public void init() {
    List<CargoRoute> cargos = bookingServiceFacade.listAllCargos();
    logger.info("All("+cargos.size()+") cargos: "+cargos);

    notRoutedCargos = cargos.stream().filter(route -> !route.isRouted()).collect(toList());
    routedUnclaimedCargos =
        cargos.stream().filter(route -> route.isRouted() && !route.isClaimed()).collect(toList());
    claimedCargos = cargos.stream().filter(CargoRoute::isClaimed).collect(toList());
  }

  public List<CargoRoute> getNotRoutedCargos() {
    return notRoutedCargos;
  }

  public List<CargoRoute> getRoutedUnclaimedCargos() {
    return routedUnclaimedCargos;
  }

  public List<CargoRoute> getClaimedCargos() {
    return claimedCargos;
  }
}
